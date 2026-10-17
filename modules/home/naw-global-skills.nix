{ inputs, ... }:

{
  imports = [ inputs.naw.homeManagerModules.globalSkills ];

  programs.naw.globalSkills = {
    enable = true;
    targets = [
      "agents"
      "claude"
    ];
    skills = {
      drawio-skill = "${inputs.drawio-skill}/skills/drawio-skill";
    };
  };
}
