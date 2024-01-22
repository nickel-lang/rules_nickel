{
  repository | String,
  chart | String,
  version | String,

  name
    | String
    | default
    = chart,
  namespace
    | String
    | default
    = name,
  create_namespace
    | Bool
    | default
    = true,

  values
    | Array String
    | optional,
  set
    | Array { name | String, value | String }
    | optional,
  depends_on
    | Array String
    | optional,
}
