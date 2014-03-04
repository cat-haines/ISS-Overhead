ISSPassTimeBase <- "http://api.open-notify.org/iss-pass.json?";

localLat <- 37.3964745
localLon <- -122.1046571
localAlt <- 32;

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
    local nextPass = GetISSPassTime(localLat, localLon, localAlt, 1);
    
    if(!nextPass) {
        // if there was an error
        passLoopWakeup = imp.wakeup(30, passLoop);
        return;
    }
    if ("riseTime" in nextPass && "duration" in nextPass) {
        // there was data 
        local timeToNextPass = nextPass.risetime - time();
        local duration = nextPass.duration;
        server.log(format("ISS be overhead next in %is for %is", timeToNextPass, duration));
        
        if(overhead) {
            // if we think we're overhead, and get we a passtime
            // then we're not overhead anymore
            overhead = false;
            device.send("notOverhead", null);
        }
        
        if (timeToNextPass < 3600) {
            // if pass is going to happen within an hour:
            
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
        }
    } else {
        // there was no data (ISS is *currently* overhead)
        if (!overhead) {
            overhead = true;
            device.send("overhead", null);
            passLoopWakeup = imp.wakeup(30.0, passLoop);
        }
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
