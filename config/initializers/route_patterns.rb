module RoutePatterns
  UUID       = /[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}/i
  ISO2       = /[A-Z]{2}/i
  ISO3       = /[A-Z]{3}/i
  REGION     = /[A-Z0-9-]{1,10}/i
  ISO_REGION = /[A-Z]{2}-[A-Z0-9-]{1,10}/i
  REF_CODE   = /[A-Za-z0-9._-]+/
  NAICS_VER  = /20\d{2}/
  NAICS_CODE = /\d{2,6}/
end
