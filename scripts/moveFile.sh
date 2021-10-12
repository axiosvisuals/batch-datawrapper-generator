curl  --request PATCH \
      --url https://api.datawrapper.de/v3/charts/$1 \
      --header 'Authorization: Bearer '$3 \
      --header 'content-type: application/json' \
      --data \
     '{
        "folderId": '$2'
      }'
