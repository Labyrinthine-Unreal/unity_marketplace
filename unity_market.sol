// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Marketplace {
    uint256 public itemCounter;
    address payable owner;
    uint256 public listingPrice;

    struct MarketItem {
        uint256 itemId;
        address nftContractAddress;
        uint256 tokenId;
        address payable seller;
        address owner;
        uint256 price;
        bool isSold;
        bool isPresent;
    }

    mapping(uint256 => MarketItem) private marketItems;

    event MarketItemListed(
        uint256 indexed itemId,
        address indexed nftContractAddress,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price
    );

    constructor() {
        itemCounter = 0;
        owner = payable(msg.sender);
        listingPrice >= 0 ether;
    }

    function listMarketItem(
        address nftContractAddress,
        uint256 tokenId,
        uint256 price
    ) public payable {
        require(msg.value == listingPrice, "Must pay the listing price");
        require(price > 0, "Price must be greater than 0");
        require(msg.sender == owner, "Only TaurosDAO's Wallet Owner Can List To Market ");

        marketItems[itemCounter] = MarketItem(
            itemCounter,
            nftContractAddress,
            tokenId,
            payable(msg.sender),
            address(0),
            price,
            false,
            true
        );

        IERC721(nftContractAddress).transferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        payable(owner).transfer(listingPrice);

        emit MarketItemListed(
            itemCounter,
            nftContractAddress,
            tokenId,
            msg.sender,
            address(0),
            price
        );

        itemCounter += 1;
    }

    function buyMarketItem(uint256 itemId) public payable {
        require(marketItems[itemId].isPresent, "Item is not present");
        require(marketItems[itemId].isSold == false, "Item is already sold");
        require(
            marketItems[itemId].price == msg.value,
            "Must pay the correct price"
        );

        marketItems[itemId].isSold = true;
        marketItems[itemId].owner = payable(msg.sender);

        IERC721(marketItems[itemId].nftContractAddress).transferFrom(
            address(this),
            msg.sender,
            marketItems[itemId].tokenId
        );
    }

    function getMarketItem(uint256 itemId)
        public
        view
        returns (MarketItem memory items)
    {
        items = marketItems[itemId];
    }

    function changeListingPrice(uint256 newPrice) public {
        require(newPrice > 0, "Listing Price must be greater than 0");
        require(
            msg.sender == owner,
            "Only the owner can change the listing price"
        );

        listingPrice = newPrice;
    }

    function withdraw() public {
        require(msg.sender == owner, "Only TaurosDAO Can Withdraw From contract");

        uint256 balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}
