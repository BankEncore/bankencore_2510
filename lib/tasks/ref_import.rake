# lib/tasks/ref_import.rake
# Usage examples:
#   bin/rails "ref:import[db/seeds/reference/**/*.yml]"
#   bin/rails ref:import["db/seeds/reference/parties.*.yml"]
#   DRY=1 bin/rails "ref:import[db/seeds/reference/**/*.yml]"    # show what would change
#   PURGE=1 bin/rails "ref:import[db/seeds/reference/**/*.yml]"  # delete values not present in files
#   VERBOSE=1 bin/rails "ref:import[...]"                        # extra logging

namespace :ref do
  desc "Import reference lists from YAML (glob path arg). ENV: DRY=1 PURGE=1 VERBOSE=1"
  task :import, [ :glob ] => :environment do |_, args|
    glob = (args[:glob].presence || "db/seeds/reference/**/*.yml")
    files = Dir.glob(glob).sort
    abort "No YAML files match #{glob.inspect}" if files.empty?

    dry    = ENV["DRY"].to_s == "1"
    purge  = ENV["PURGE"].to_s == "1"
    noisy  = ENV["VERBOSE"].to_s == "1"

    require Rails.root.join("app/services/reference/yaml_importer")

    total_lists = 0
    total_vals  = 0
    changed     = 0

    files.each do |path|
      puts "→ #{path}" if noisy
      result = Reference::YamlImporter.call(path:, dry:, purge:, verbose: noisy)
      total_lists += result[:lists]
      total_vals  += result[:values]
      changed     += result[:changed]
    end

    puts "\nImported #{total_lists} list(s), #{total_vals} value(s). Changed: #{changed}#{dry ? ' (dry-run)' : ''}"
  end
end
