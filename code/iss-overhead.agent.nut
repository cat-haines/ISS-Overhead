HTML <- @"
    <!DOCTYPE html>
    <html>
        <head>
            <title>ISS Overhead</title>
            
            <link rel='stylesheet' href='https://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css' />
            <link rel='stylesheet' href='https://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css'>
            
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <style>
                .center { margin-left: auto; margin-right: auto; margin-bottom: auto; margin-top: auto; }
            </style>
        </head>
        <body>
            <div class='container'>
                <h1 class='text-center'>ISS Overhead</h1>
                <form role='form' class='col-xs-12 col-sm-offset-2 col-sm-8' style='border-width: 1px; border-color:#ddd; border-radius:4px; border-style:solid; padding: 20px;'>
                    <div class='form-group'>
                        <label for='latitude'>Latitude</label>
                        <input type='text' class='form-control' id='latitude' placeholder='%s'>
                    </div>
                    <div class='form-group'>
                        <label for='longitude'>Longitude</label>
                        <input type='text' class='form-control' id='longitude' placeholder='%s'>
                    </div>
                    <div class='form-group'>
                        <label for='altitude'>Altitude</label>
                        <input type='text' class='form-control' id='altitude' placeholder='%s'>
                    </div>
                    <button type='submit' class='btn btn-default'>Update Settings</button>
                </form>
                <div class='col-xs-12 col-sm-offset-2 col-sm-8' style='margin-top: 20px'>
                    <button onclick='test();' class='btn btn-default'>Test for 30 seconds</button>
                </div>
                <div class='footer col-xs-12' style='text-align: center; margin-top: 10px;'>
                    <a href='http://electricimp.com'><img src='https://electricimp.com/public/img/logomobile.png' class'img-rounded'></a>
                </div>
            </div>
            
            <script src = 'https://code.jquery.com/jquery-1.10.1.min.js'></script>
            <script src = 'https://code.jquery.com/jquery-migrate-1.2.1.min.js'></script>
            <script src = 'https://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js'></script>
            <script src = 'https://code.jquery.com/ui/1.10.3/jquery-ui.js'></script>
            <script>
                var baseUrl = '%s';
            
                function logSuccess(title, message) {
                    var t = new Date().getTime();
                    $('.container').prepend('<div id=\'' + t + '\' class=\'alert alert-success\' style=\'margin-top:10px\'><button type=\'button\' class=\'close\' data-dismiss=\'alert\'>x</button><strong>' + title + '</strong>&nbsp;' + message + '</div>');
                    window.setTimeout(function() { $('#' + t).alert('close'); }, 3000);
                }
        
                function logError(title, message) {
                    var t = new Date().getTime();
                    $('.container').prepend('<div id =\'' + t + '\'class=\'alert alert-error\' style=\'margin-top:10px\'><button type=\'button\' class=\'close\' data-dismiss=\'alert\'>x</button><strong>' + title + '</strong>&nbsp;' + message + '</div>');
                    window.setTimeout(function() { $('#' + t).alert('close'); }, 3000);
                }

                function update(data) {
                    $('#latitude').val(data.lat);
                    $('#longitude').val(data.lon);
                    $('#altitude').val(data.alt);
                }

                $('form').on('submit',function(e){
                    e.preventDefault();
                    var data = {
                        lat: $('#latitude').val(),
                        lon: $('#longitude').val(),
                        alt: $('#altitude').val()
                    };
                    console.log(data)
                    $.ajax({
                        type     : 'POST',
                        cache    : false,
                        url      : baseUrl + '/settings',
                        data     : data,
                        success  : function(d) {
                            update(d);
                            logSuccess('Success', 'Settings have been updated.');
                        },
                        error   : function(d) {
                            logError('Error', 'Could not update - please try again.');
                        }
                    });
                });
                
                function test() {
                    $.ajax({
                        type    : 'GET',
                        url     : baseUrl + '/test',
                        success : function(data) {
                            logSuccess('Success', 'Your box should glow for 30 seconds');
                        }
                    });
                }

                $(document).ready(function() {
                    $.ajax({
                        type    : 'GET',
                        url     : baseUrl + '/settings',
                        success : function(data) {
                            update(data);
                        }
                    });
                });

            </script>
        </body>
    </html>
";

ISSPassTimeBase <- "http://api.open-notify.org/iss-pass.json?";

function setPosition(newLat, newLon, newAlt) {
    settings = {
        lat = newLat,
        lon = newLon,
        alt = newAlt 
    };
    server.save(settings);
    //server.log("Set position: " + settings.lat + ", " + settings.lon + " (" + settings.alt + "m)");
} 

settings <- server.load();
if (settings == null || !("lat" in settings) || !("lon" in settings) || !("alt" in settings)) {
    //lat,lon, alt (m) - default set to Amherst, MA
    setPosition(42.45338,-72.565285,90);
} else {
    //server.log("Loaded position: " + settings.lat + ", " + settings.lon + " (" + settings.alt + "m)");
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
    
    if(!nextPass || !("risetime" in nextPass) || !("duration") in nextPass) {
        // if there was an error
        passLoopWakeup = imp.wakeup(30, passLoop);
        server.log("Error getting ISS pass time. Trying again in 30 seconds. ");
        return;
    }

    // there was data 
    local timeToNextPass = nextPass.risetime - time();
    local duration = nextPass.duration;
    
    if(overhead) {
        // if we think we're overhead, and get we a passtime
        // then we're not overhead anymore
        overhead = false;
        device.send("notOverhead", null);
        
        //server.log("ISS is no longer overhead.")
    }
    
    if (timeToNextPass < 3600) {
        // if pass is going to happen within an hour:
        //server.log("ISS will be overhead in " + timeToNextPass/60 + " minutes.");
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
        //server.log("ISS is " + timeToNextPass / 3600 + " hours away.");
    }
} passLoop();

function passLoopWatchDog() {
    // wakeup every 30 minutes to make sure things are fine
    imp.wakeup(1500, passLoopWatchDog);
    if (passLoopWakeup == null) {
        //server.log("restarted loop");
        passLoop();
    }
} passLoopWatchDog();

http.onrequest(function(req, resp) {
    try {
        local path = req.path.tolower();
        local method = req.method.toupper();
        
        if (path == "/test" || path == "/test/") {
            if (overhead) return;
            device.send("overhead", 30);
        }
        
        if (path == "/settings" || path == "/settings/") {
            local changed = false;

            local data = http.urldecode(req.body);
            
            local lat = settings.lat;
            if ("lat" in data) {
                changed = true;
                lat = data.lat.tofloat();
            } 
            
            local lon = settings.lon;
            if ("lon" in data) {
                changed = true;
                lon = data.lon.tofloat();
            } 
            
            local alt = settings.alt;
            if ("alt" in data) {
                changed = true;
                alt = data.alt.tofloat();
            }
            
            if (changed) setPosition(lat, lon, alt);
            
            resp.header("content-type", "application/json");
            resp.send(200, http.jsonencode(settings));
            return;
        }
        
        resp.send(200, format(HTML, settings.lat.tostring(), settings.lon.tostring(), settings.alt.tostring(), http.agenturl()));
    } catch (ex) {
        resp.send(500, "Agent Error: " + ex);
    }        
});

//server.log("Agent Started");
