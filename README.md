# Information

(Work in progress) Basic backend for a cryptocurrency exchange using a created
ERC20 (PresetMinterPauser) token

## Functionality:

- Change Price
- Set ask and bid price
- Get lowest ask price
- get spread
- market buy/sell tokens

## Notes

The exchange offers a base rate unless there a worse deal in the bid/ask price (to simulate a spread)

# Installation

Eth-brownie should be installed. Please visit their documentation to get
a full picture of how to install it.

# Potential Improvements

## Testing 

Previously tested on rinkeby (in Remix)

1. Add a reset function, to save time via not needing to re-deploy the contract
2. Create mock contracts that are in the specified test states already, to save time
   ...

## Functionality

1. Prompt for approval to transfer a base amount of input token, instead of manually approving
2. Add extra exchange functionality such as (more tokens, limit orders, volume etc.)
   ...
# backend-crypto-exchange-v1
