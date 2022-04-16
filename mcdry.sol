// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

interface WETH {
    function deposit() external payable;
    function transferFrom(address src, address dst, uint wad) external returns (bool);
    function withdraw(uint wad) external;
}

interface McDryNFT {
    function mint(uint _numberOfTokens) external payable;
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract McDry is IERC721Receiver {
    WETH public weth = WETH(0xc778417E063141139Fce010982780140Aa0cD5Ab);
    McDryNFT public mcdrynft = McDryNFT(0x0A6cD94bDbD89D44D419dF1D497f77Fd1d7FADAD);

    address public owner;
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "You`re not an owner!");
        _;
    }

    receive() external payable{
        pay();
    }

    fallback() external payable{
        pay();
    }

    function multiMint(uint txCount, uint nftAmount) external payable onlyOwner{
        for (uint i = 0; i < txCount; i++){
            mcdrynft.mint{value: msg.value / txCount}(nftAmount);
        }
    }

    function withdrawNft(uint[] calldata tokenIds) external onlyOwner {
        for (uint i = 0; i < tokenIds.length; i++){
            mcdrynft.transferFrom(address(this), owner, tokenIds[i]);
        }
    }

    function swapETHtoWETH() external payable onlyOwner{
        weth.deposit{value: msg.value}();
    }

    function swapWETHtoETH(uint amount) external onlyOwner{
        weth.withdraw(amount);
        address payable receiver = payable(owner);
        uint balance = address(this).balance;
        receiver.transfer(balance);  
    }

    function withdrawWETH(uint amount) external onlyOwner{
        weth.transferFrom(address(this), owner, amount);
    }

    function pay() public payable {}

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }


}
