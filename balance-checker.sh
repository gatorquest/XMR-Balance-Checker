#!/bin/bash
# e.g: /home/user/Monero/wallets
WALLETS_DIR="Your_wallet_location_folder"

total_balance=0.0000000

declare -A processed_wallets

for wallet_folder in "$WALLETS_DIR"/*; do
    if [ -d "$wallet_folder" ]; then

        wallet_name=$(basename "$wallet_folder")

	primary_address=$(echo -e "\n" | monero-wallet-cli --wallet-file "$wallet_folder/$wallet_name" address primary | grep "Opened wallet: " | awk '{print $3}')

	if [ -n "${processed_wallets[$primary_address]}" ]; then
            echo "Skipping duplicate wallet: $primary_address"
            continue
        fi

        processed_wallets["$primary_address"]=1

      	#sync_status=$(echo -e "\n" | monero-wallet-cli --wallet-file "$wallet_folder/$wallet_name" refresh | grep "Refresh done, blocks received:")
      
      	#if [ -n "$sync_status" ]; then
      	#    echo "Wallet is fully synchronized."
      	#else
      	#    sync_percentage=$(echo "$sync_status" | awk '{print $6}')
      	#    echo "Synchronization progress: $sync_percentage"
      	#fi

        # Run monero-wallet-cli to get the balance (press Enter when prompted for a password)
        balance=$(echo -e "\n" | monero-wallet-cli --wallet-file "$wallet_folder/$wallet_name" balance | grep "Balance:" | awk '{print $2}')
        balance=$(echo "$balance" | sed 's/,$//')

	echo "Adding balance: $balance"
	total_balance=$(echo $total_balance $balance | awk '{print $1 + $2}')
	echo "New total balance: $total_balance"
        echo "Wallet: $wallet_name"
        echo "Address: $primary_address"
        echo "Balance: $balance XMR"
        echo "Total So Far: $total_balance XMR"
        echo
    fi
done

echo "Overall Total XMR: $total_balance XMR"
