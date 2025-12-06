#!/bin/bash
REGIONS=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)
for region in $REGIONS; do
  price=$(aws ec2 describe-spot-price-history --instance-types c7i.12xlarge --region "$region" --product-descriptions "Linux/UNIX" --max-results 1 --query 'SpotPriceHistory[0].SpotPrice' --output text 2>/dev/null)
  if [ -n "$price" ] && [ "$price" != "None" ]; then
    echo "$price $region"
  fi
done | sort -n
