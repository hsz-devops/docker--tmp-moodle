This image has one sole purpose - speedup build of other moodle images.
It does this by having moodle sources pre-fetched (git or curl) to a predefined location.
All there is left to do is use it as intermediate container in multi-stage builds.
