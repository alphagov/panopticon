#!/usr/bin/env bash

# This script merges the Mongo databases for Panopticon and Publisher.
#
# You need to run this script on the machine where the Mongo databases live (or
# the primary replica, in the case of a replica set). Alternatively, you can
# pipe the script into an ssh session:
#
#   ssh -F /path/to/ssh_config <server_name> 'bash -s <environment>' < create_govuk_content_database.sh
#
# To find which Mongo server is primary, the quickest way is probably to SSH
# into them in turn and check for "PRIMARY>" in the Mongo prompt.

ENVS="development preview production"

# We can safely restore the indexes from Panopticon and Publisher because the
# only clashing collection is users, which has the same indexes in each

# Users in Publisher are referred to from their actions, so they get restored;
# users in Panopticon get generated on login and aren't referred to from other
# models, so we can safely throw them away.

PANOPTICON_COLLECTIONS="artefacts contacts tags system.indexes"

read -d '' PUBLISHER_COLLECTIONS <<END
  authorities editions local_authorities local_services
  local_transactions_source_lgsls local_transactions_sources
  mr_publications_count_by_this._type mr_publications_count_by_this.department
  mr_publications_count_by_this.section overview_dashboards publications
  publications2 whole_editions users system.indexes
END

function usage {
  cat <<END
Usage: $0 [development|preview|production]
END
}

case $1 in
  development )
    CONTENT_DB_NAME="govuk_content_development"
    PANOPTICON_DB_NAME="panopticon_development"
    PUBLISHER_DB_NAME="mguides_development2"
    ;;
  preview|production )
    CONTENT_DB_NAME="govuk_content_production"
    PANOPTICON_DB_NAME="panopticon_production"
    PUBLISHER_DB_NAME="publisher_production"
    ;;
  * )
    usage
    exit 1
esac

# Check whether the database exists: bail if it does
echo 'show collections' | mongo --quiet $CONTENT_DB_NAME | grep -v '^bye$' | grep . >/dev/null

if [[ $? -eq 0 ]]; then
  echo "ERROR: database $CONTENT_DB_NAME already exists"
  echo "If you *really* want to rebuild this database, drop it first"
  exit 2
fi

set -e  # Bail on errors

# Word of warning: mongorestore will return a zero status code even if it all
# goes horribly wrong, so we have no sane way of knowing whether this worked.
# See <https://jira.mongodb.org/browse/SERVER-1994>

rm -rf ./*_dump

mongodump -d $PANOPTICON_DB_NAME -o panopticon_dump
for coll in $PANOPTICON_COLLECTIONS; do
  echo "Migrating $coll from Panopticon"
  mongorestore -d $CONTENT_DB_NAME -c $coll ./panopticon_dump/$PANOPTICON_DB_NAME/$coll.bson
done

mongodump -d $PUBLISHER_DB_NAME -o publisher_dump
for coll in $PUBLISHER_COLLECTIONS; do
  echo "Migrating $coll from publisher"
  mongorestore -d $CONTENT_DB_NAME -c $coll ./publisher_dump/$PUBLISHER_DB_NAME/$coll.bson
done
