// SPDX-License-Identifier: MIT

// A simulated cryptocurrency exchange
// Requires:
// 1. Deployed ERC20PresetMinterPauser token
// 2. Tokens sent to the contract
// 3. Approval for the contract to sell your tokens for ETH
// 4. tPE = tokensPerETH

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract TestExchange {
  ERC20PresetMinterPauser inputToken;

  // Made the tokensPerETH 1000 for inital simplicity of calculation
  uint256 public tokensPerETH = 1000;

  address public deployer;

  uint256[] public AsksintokensPerETH;

  uint256[] public BidsintokensPerETH;

  uint256 public max;

  uint256 public min;

  function changePrice(uint256 _tokensPerETH) public {
    tokensPerETH = _tokensPerETH;
  }

  function displayTokenBalance() public view returns (uint256) {
    uint256 balance = (inputToken.balanceOf(address(this))) /
      10**inputToken.decimals();
    return balance;
  }

  function setAskPrice(uint256 _askPrice) public {
    AsksintokensPerETH.push(_askPrice);
  }

  function setBidPrice(uint256 _bidPrice) public {
    BidsintokensPerETH.push(_bidPrice);
  }

  // Gets the lowest ask price which is the highest tokens per ETH (tPE) ask
  // tpE UP --> Price of token DOWN
  // Token is cheaper: You can get more tokens with your ETH
  function getLowestAskPrice() public returns (uint256) {
    max = AsksintokensPerETH[0];
    for (uint256 i = 0; i < AsksintokensPerETH.length; i++) {
      if (max < AsksintokensPerETH[i]) {
        max = AsksintokensPerETH[i];
      }
    }
    return max;
  }

  // Gets the highest bid price which is the lowest tPE bid
  // tPE DOWN --> Price of token UP
  // Token is more expensive: You can get more ETH with your tokens
  function getHighestBidPrice() public returns (uint256) {
    min = BidsintokensPerETH[0];
    for (uint256 i = 0; i < BidsintokensPerETH.length; i++) {
      if (min > BidsintokensPerETH[i]) {
        min = BidsintokensPerETH[i];
      }
    }
    return min;
  }

  function getSpread() public view returns (uint256) {
    uint256 spread = min - max;
    return spread;
  }

  // Input the desired token address and set it as a variable of type TestToken
  constructor(address tokenAddress) {
    deployer = msg.sender;
    inputToken = ERC20PresetMinterPauser(tokenAddress);
    // inputToken.increaseAllowance(address(this), 10*10**inputToken.decimals());
    // inputToken.transferFrom(msg.sender, address(this), 10*10**inputToken.decimals());
  }

  function marketBuyTokens(uint256 _tokensToBuy)
    public
    payable
    returns (uint256)
  {
    max = getLowestAskPrice();

    // Setting the token price as the lowest ask price
    // only if there is an active ask
    // Why max tPE? --> Best buyer option is the highest tPE
    // 1 token price: @ 1 tPE = 1 ETH, @  5 tpE = 0.2 ETH
    if (AsksintokensPerETH.length > 0 && max < tokensPerETH && max != 0) {
      tokensPerETH = max;
    }

    uint256 ValueBoughtinWei = (_tokensToBuy * 10**inputToken.decimals()) /
      (tokensPerETH);

    // Making sure the transaction value is greater than the price it would cost to buy
    // the desired amount of tokens (in wei)
    require(
      msg.value >= ValueBoughtinWei,
      "You need to send more ETH to proceed"
    );

    uint256 vendorBalance = inputToken.balanceOf(address(this));
    require(
      vendorBalance >= _tokensToBuy * 10**inputToken.decimals(),
      "Vendor contract has not enough tokens to perform transaction"
    );

    // Makes sure the transaction actually gets sent
    bool sent = inputToken.transfer(
      msg.sender,
      _tokensToBuy * 10**inputToken.decimals()
    );
    require(sent, "Failed to transfer token to user");

    return ValueBoughtinWei;
  }

  function marketSellTokens(uint256 _tokensToSell) public {
    require(_tokensToSell > 0, "Specify an amount of token greater than zero");

    min = getHighestBidPrice();

    // Setting the token price as the highest bid price
    // only if there is an active bid
    // Why min? --> Best seller option is the lowest tPE
    // 1 token price: @ 1 tPE = 1 ETH, @  5 tpE = 0.2 ETH
    if (BidsintokensPerETH.length > 0 && min > tokensPerETH) {
      tokensPerETH = min;
    }

    uint256 userBalance = inputToken.balanceOf(msg.sender);
    require(
      userBalance >= _tokensToSell * 10**inputToken.decimals(),
      "You have insufficient tokens"
    );

    // Example: 100 tokens to sell at 5 tokens per eth
    // 100 tokens/5 = 20 eth received
    uint256 amountOfETHToTransfer = (_tokensToSell *
      10**inputToken.decimals()) / tokensPerETH;
    uint256 vendorETHBalance = address(this).balance;
    require(
      vendorETHBalance >= amountOfETHToTransfer,
      "Vendor has insufficient funds"
    );

    bool sent = inputToken.transferFrom(
      msg.sender,
      address(this),
      _tokensToSell * 10**inputToken.decimals()
    );
    require(sent, "Failed to transfer tokens from user to vendor");

    // Sends the function caller the value with (no payload data (?))
    (sent, ) = msg.sender.call{ value: amountOfETHToTransfer }("");
    require(sent, "Failed to send ETH to the user");
  }

  modifier OnlyDeployer() {
    require(
      deployer == msg.sender,
      "You are not the deployer of this contract"
    );
    _;
  }

  function withdraw() public OnlyDeployer {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "No ETH present in Vendor");

    (bool sent, ) = msg.sender.call{ value: address(this).balance }("");
    require(sent, "Failed to withdraw");
  }
}
