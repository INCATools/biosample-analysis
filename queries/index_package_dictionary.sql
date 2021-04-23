CREATE UNIQUE INDEX if not exists package_name ON
package_dictionary(Name);

CREATE INDEX if not exists package_dictionary_combo ON
package_dictionary(tidy_EnvPackage,
tidy_EnvPackageDisplay,
tidy_checklist);
