JSON=$(curl -s --request GET \
      --url https://api.datawrapper.de/v3/charts/${2}/assets/${2}.map.json \
      --header "Authorization: Bearer ${3}")

curl  --request PATCH \
      --url https://api.datawrapper.de/v3/charts/${1} \
      --header "Authorization: Bearer ${3}" \
      --header 'content-type: application/json' \
      --data \
       '{
          "metadata": {
            "visualize": {
                "basemap": "custom_upload"
            }
          }
      }'

curl  --request PUT \
      --url https://api.datawrapper.de/v3/charts/${1}/assets/${1}.map.json \
      --header "Authorization: Bearer ${3}" \
      --header 'content-type: application/json' \
      --data "$JSON"
