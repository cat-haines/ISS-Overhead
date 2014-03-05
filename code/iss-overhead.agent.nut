ISSPassTimeBase <- "http://api.open-notify.org/iss-pass.json?";

function setPosition(newLat, newLon, newAlt) {
    settings = {
        lat = newLat,
        lon = newLon,
        alt = newAlt
    };
    server.save(settings);
    server.log("Set position: " + settings.lat + ", " + settings.lon + " (" + settings.alt + "m)");
}

settings <- server.load();
if (settings == null || !("lat" in settings) || !("lon" in settings) || !("alt" in settings)) {
    setPosition(37.3964745,-122.1046571,32);
} else {
    server.log("Loaded position: " + settings.lat + ", " + settings.lon + " (" + settings.alt + "m)");
}

foreach(k,v in settings)

overhead <- false;
passLoopWakeup <- null;

function GetISSPassTime(latitude, longitude, altitude = 0, passes = 5) {
    local params = { lat = latitude, lon = longitude, alt = altitude, n = passes };
    local url = ISSPassTimeBase + http.urlencode(params);

    try {
        local result = http.get(url).sendsync();
        if (result.statuscode != 200) throw("Something went horribly wrong: " + result.statuscode + " - " + result.body);
        local data = http.jsondecode(result.body);
        if (data.response.len() == 1) return data.response[0];
        return data.response;
    } catch (ex) {
        server.log(ex);
        return null;
    }
}

function passLoop() {
    local nextPass = GetISSPassTime(settings.lat, settings.lon, settings.alt, 1);
    
    if(!nextPass) {
        // if there was an error
        passLoopWakeup = imp.wakeup(30, passLoop);
        server.log("Error getting ISS pass time. Trying again in 30 seconds. ");
        return;
    }
    if ("risetime" in nextPass && "duration" in nextPass) {
        // there was data 
        local timeToNextPass = nextPass.risetime - time();
        local duration = nextPass.duration;
        
        if(overhead) {
            // if we think we're overhead, and get we a passtime
            // then we're not overhead anymore
            overhead = false;
            device.send("notOverhead", null);
            
            server.log("ISS is no longer overhead.")
        }
        
        if (timeToNextPass < 3600) {
            // if pass is going to happen within an hour:
            server.log("ISS will be overhead in " + timeToNextPass/60 + " minutes.");
            // schedule device on
            imp.wakeup(timeToNextPass-10, function() { 
                overhead = true;
                device.send("overhead", duration); 
            });
            // schedule device off
            imp.wakeup(timeToNextPass+duration+10, function() { 
                overhead = false;
                device.send("notOverhead", null); 
            });
            // schedule get next pass
            passLoopWakeup = imp.wakeup(timeToNextPass+duration+30, passLoop)
        }
        else {
            // if pass is more than hour away, wake up in an hour and check
            passLoopWakeup = imp.wakeup(3600, passLoop);
            server.log("ISS is more than an hour away.");
        }
    } else {
        // there was no data (ISS is *currently* overhead)
        if (!overhead) {
            overhead = true;
            device.send("overhead", null);
            
            server.log("ISS is currently overhead.");
        } 
        else { server.log("ISS is still overhead."); }
        
        passLoopWakeup = imp.wakeup(30.0, passLoop);
    }
} passLoop();

function passLoopWatchDog() {
    // wakeup every 30 minutes to make sure things are fine
    imp.wakeup(1500, passLoopWatchDog);
    if (passLoopWakeup == null) {
        server.log("restarted loop");
        passLoop();
    }
} passLoopWatchDog();

http.onrequest(function(req, resp) {
    local path = req.path.tolower();
    local method = req.method.toupper();
    local data = req.query;
    
    if (path == "/settings" || path == "/settings/") {
        local changed = false;
        
        local lat = settings.lat;
        if ("lat" in data) {
            changed = true;
            lat = data.lat;
        } 
        
        local lon = settings.lon;
        if ("lon" in data) {
            changed = true;
            lon = data.lon;
        } 
        
        local alt = settings.alt;
        if ("alt" in data) {
            changed = true;
            alt = data.alt;
        }
        
        if (changed) setPosition(lat, lon, alt);
        
        resp.header("content-type", "application/json");
        resp.send(200, http.jsonencode(settings));
        return;
    }
    
    resp.send(200, "OK");
});
