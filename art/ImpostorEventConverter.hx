package art;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

using StringTools;

// convert impostor v4 chart events into fps plus format and do some cool stuff idkkk
class ImpostorEventConverter
{
    static var fpsPlusEvents:Array<Array<Dynamic>> = []; // uh
    static var curSection:Int = 0;
    
    public static function main()
    {
        trace("Enter events.json Path!");
		var dataPath = Sys.stdin().readLine().trim();

		if (!FileSystem.exists(dataPath))
		{
			trace('No Event File Exist on ($dataPath) !!');
			return;
		}
        var impostorJson:PsychEventsLegacy = Json.parse(File.getContent(dataPath)).song;
        
        var ignoreEvents:Array<String> = [];
        curSection = 0;
        for (section in impostorJson.notes)
        {
            for (event in section.sectionNotes)
            {
                // then doing converting stuff lol
                var eventTime = event[0];
                var eventName = event[2];
                var eventValue1 = event[3];
                var eventValue2 = event[4];

                if (ignoreEvents.contains(eventName))
                    continue;

                switch(eventName)
                {
                    case "Add Camera Zoom":
                        pushEvent("camBop", [], eventTime);
                    case "Change Character":
                        var char:Int = Std.parseInt(eventValue1);
                        if (Math.isNaN(char))
                        {
                            switch (eventValue2.toLowerCase())
				            {
					            case 'mom' | 'opponent2':
						            char = 3;
					            case 'gf' | 'girlfriend':
					            	char = 2;
					            case 'dad' | 'opponent':
					    	        char = 1;
                                default:
                                    char = 0;
                            }
                        }
                        
                        var actualChar = ["bf", "dad", "gf"][char];
                        pushEvent("changeCharacter", [actualChar, eventValue2], eventTime);
                    case "Play Animation":
                        var char = eventValue2.toLowerCase();
                        if (eventValue2 == "0") char = "dad";
                        if (eventValue2 == "1" || eventValue2 == "boyfriend") char = "bf";
                        if (eventValue2 == "2" || eventValue2 == "girlfriend") char = "gf";

                        pushEvent("playAnim", [char, eventValue1, true], eventTime);

                    // sussy events
                    case "flash":
                        var type:Int = Std.parseInt(eventValue1);
                        if (Math.isNaN(type))
                            type = 0;
                        // todo: implement identity crisis shits
                        switch (type)
					    {
						    case 0 | 1:
                                pushEvent("flash", ["0.35"], eventTime);
						    case 2:
						    	pushEvent("flash", ["0.55"], eventTime);
						    	// darkMono.visible = true;
						    case 3:
						    	pushEvent("flash", ["0.55"], eventTime);
						    	// darkMono.visible = false;
						    	// saxguy.visible = false;
						    }
                        
                    case "Reactor Beep":
                        pushEvent("reactorBeep", [eventValue1], eventTime);

                    
                    case "Meltdown Video":
                        pushEvent("deadBodyReport", [], eventTime);

                    case "Defeat Retro":
                        if (eventValue1 == "0")
                        {
                            pushEvent("turnsOld", [], eventTime);
                        }else{
                            pushEvent("turnsNew", [], eventTime);
                            pushEvent("changeCharacter", ["bf", "BfDefeatScared"], eventTime, 1);
                            pushEvent("changeCharacter", ["dad", "Black"], eventTime, 2);
                        }
                    case "Defeat Fade":
                        if (eventValue1 == "0")
                            pushEvent("fadeInBodies", [], eventTime);
                        if (eventValue1 == "1")
                            pushEvent("fadeOutBodies", [], eventTime);
                    
                    // ignoring these shit cuz yes
                    case "DefeatDark":
                        // does nothin

                    default:
                        // Don't you think it's ridiculous to give multiple notices????????
                        trace("Found undefined event " + eventName + "! ignoring....");
                        ignoreEvents.push(eventName);
                }
            }
            curSection += 1;
        }

        File.saveContent(dataPath.split(".json")[0] + "-converted.json", Json.stringify({events: {events: fpsPlusEvents}}, "\t"));
    }

    static function pushEvent(name:String, args:Array<Dynamic>, time:Float, id:Int = 0)
    {
        if (args.join(";").length < -1)
            args = [];
        
        if (args.length > 0)
            name += ";";

        fpsPlusEvents.push(
            [
                curSection,
                time,
                id,
                name + args.join(";")
            ]
        );
    }
}

// Only the bare minimum
typedef PsychEventsLegacy = {
    var notes:Array<PsychSection>;
}

typedef PsychSection = {
    var sectionNotes:Array<Array<Dynamic>>;
}