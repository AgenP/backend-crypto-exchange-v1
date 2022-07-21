// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
// Goals:
// owner can mint
// owner can burn
// Large initial supply

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract Price_Control is ERC20PresetMinterPauser {
  // Initalising this variable so it can be used in the modifier
  address public deployer;

  constructor() ERC20PresetMinterPauser("PriceTest", "PT") {
    deployer = msg.sender;
    _mint(msg.sender, 100000 * 10**18);
  }

  modifier OnlyDeployer() {
    require(
      deployer == msg.sender,
      "You are not the deployer of this contract"
    );
    _;
  }

  // Setting the OnlyDeployer modifier to the burn function
  // (Pause and mint already have a modifier preset)
  function burn(uint256 amount) public override OnlyDeployer {
    _burn(_msgSender(), amount);
  }
}
