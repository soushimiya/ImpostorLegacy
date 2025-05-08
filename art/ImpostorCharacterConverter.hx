package art;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

using StringTools;

// PLS DO NOT SAY I'M LAZY BASED ON MY OLD PSYCH 2 FPS CONVETER THANKS
class ImpostorCharacterConverter
{
    static var fpsPlusEvents:Array<Array<Dynamic>> = []; // uh
    static var curSection:Int = 0;
    
    public static function main()
    {
        trace("Enter character's '.json' file path!");
		var dataPath = Sys.stdin().readLine().trim();

		if (!FileSystem.exists(dataPath))
		{
			trace('No Character File Exist on ($dataPath) !!');
			return;
		}
        trace("Set character name!");
		var exportName = Sys.stdin().readLine().trim();

        final psychChar:Dynamic = Json.parse(File.getContent(dataPath));
        // uh i think this is awesome
		var charScript = 'class $exportName extends CharacterInfoBase{public function new(){super();';
        var animList:Array<Dynamic> = psychChar.animations;
        for (anim in animList){
            if (anim.indices.length < 1)
                charScript += 'addByPrefix("${anim.anim}", offset(${anim.offsets[0]}, ${anim.offsets[1]}), "${anim.name}", ${anim.fps}, loop(${anim.loop}));';
            else 
                charScript += 'addByIndices("${anim.anim}", offset(${anim.offsets[0]}, ${anim.offsets[1]}), "${anim.name}", ${anim.indices.toString()}, "", ${anim.fps}, loop(${anim.loop}));';
        }

        //Convert metadata
        if (!psychChar.antialiasing)
		    charScript += 'info.antialiasing = ${!psychChar.no_antialiasing};';
		charScript += 'info.spritePath = "${psychChar.image}";';
        if (psychChar.position != [0, 0])
		    charScript += 'addExtraData("reposition", [${psychChar.position[0] - 230}, ${psychChar.position[1] - 20}]);';
		charScript += 'info.iconName = "${psychChar.healthicon}";';
        if (psychChar.flip_x)
		    charScript += 'info.facesLeft = ${psychChar.flip_x};';
		charScript += 'info.healthColor = ${rgbToHex(psychChar.healthbar_colors[0], psychChar.healthbar_colors[1], psychChar.healthbar_colors[2])};';
		if (psychChar.camera_position != [0, 0])
            charScript += 'info.focusOffset.set(${psychChar.camera_position[0]}, ${psychChar.camera_position[1]});';
        if (psychChar.scale != 1)
            charScript += 'addExtraData("scale", ${psychChar.scale});';

        trace("Enter the save directory!");
		var saveFolder = Sys.stdin().readLine().trim();
        File.saveContent(saveFolder + '/$exportName.hxc', charScript + "}}");
    }

	static final hexCodes = "0123456789ABCDEF";
	static function rgbToHex(r:Int, g:Int, b:Int):String
	{
		var hexString = "0xFF";
		//Red
		hexString += hexCodes.charAt(Math.floor(r/16));
		hexString += hexCodes.charAt(r%16);
		//Green
		hexString += hexCodes.charAt(Math.floor(g/16));
		hexString += hexCodes.charAt(g%16);
		//Blue
		hexString += hexCodes.charAt(Math.floor(b/16));
		hexString += hexCodes.charAt(b%16);
		
		return hexString;
	}
}