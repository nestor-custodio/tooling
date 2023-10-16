
# Recursively replaces all object/array *values* with a `null`.
#
def deep_sanitize: if ([type] | inside(["object", "array"])) then map_values(deep_sanitize) else null end;
