blinking <- false;
blinkPeriod <- 0.5;

blinkWakeup <- null;
blinkOffWakeup <- null;

led <- hardware.pin9;
led.configure(DIGITAL_OUT);

function setLedBlinkPeriod(period) {
    blinkPeriod = period;
}

function ledOn(data = null) { 
    stopBlink();
    led.write(1); 
}

function ledOff(data = null) { 
    stopBlink();
    led.write(0); 
}

function ledBlink(duration = null) {
    if (duration) { 
        blinking = true;
        imp.wakeup(duration, ledOff);
    }

    if (!blinking) return;
    
    imp.wakeup(blinkPeriod, ledBlink)
    led.write(1-led.read());
}

function stopBlink() {
    if(blinkWakeup != null) imp.cancelwakeup(blinkWakeup);
    if(blinkOffWakeup != null) imp.cancelwakeup(blinkOffWakeup)
    blinking = false;
}

agent.on("error", ledOn);

agent.on("waiting", ledOff);

agent.on("overhead", function(d) { ledBlink(d); });

agent.on("blinkspeed", function(p) { setLedBlinkPeriod(p); });

ledOff();

