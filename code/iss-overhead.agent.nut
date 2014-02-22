ISSPassTimeBase <- "http://api.open-notify.org/iss-pass.json?";

localLat <- YOUR_LAT
localLon <- YOUR_LON
localAlt <- YOUR_ALT

passStartWakeup <- null;
passEndWakeup <- null;

function GetNextISSPassTime(latitude, longitude, altitude = 0, passes = 5) {
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
    local nextPass = GetNextISSPassTime(localLat, localLon, localAlt, 1);
    try {
        if (!nextPass) throw "No information for next pass.";
        local timeToNextPass = nextPass.risetime - time();
        local duration = nextPass.duration;
        
        server.log(format("ISS be overhead next in %is for %is", timeToNextPass, duration));
        
        // cancel / overwrite any previous timers
        if (passStartWakeup != null) imp.cancelwakeup(passStartWakeup);
        if (passEndWakeup != null) imp.cancelwakeup(passEndWakeup);
        passStartWakeup = imp.wakeup(timeToNextPass, function() { device.send("overhead", duration); });
        passEndWakeup = imp.wakeup(timeToNextPass+duration+30, passLoop);
    } catch(ex) { 
        server.log("Error: " + ex);
        device.send("error", null);
    }
} passLoop();

function passLoopWatchDog() {
    imp.wakeup(600, passLoopWatchDog);
    if (passStartWakeup == null && passEndWakeup == null) passLoop();
} passLoopWatchDog();

