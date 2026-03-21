{ ... }:

{
  programs.codex = {
    enable = true;
    settings = {
      model = "ark-code-latest";
      model_provider = "volcengine";
      model_providers = {
        volcengine = {
          name = "volcengine";
          base_url = "https://ark.cn-beijing.volces.com/api/coding/v3";
          env_key = "VOLCENGINE_API_KEY";
          wire_api = "chat";
          requires_openai_auth = false;
        };
      };
    };
  };
}
