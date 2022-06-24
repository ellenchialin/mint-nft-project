// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// Hardhat allows us to console logs in contract
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 public totalSupply = 50;

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = ["Fantastic", "Epic", "Terrible", "Crazy", "Wild", "Spooky", "Amazing", "Lucky", "Glorious", "Rude", "Pure", "Fresh", "Sharp", "Needy", "Energetic"];
    string[] secondWords = ["Gray", "Telemagenta", "PastelGreen", "CobaltBlue", "ChestnutBrown", "GoldenYellow", "LightIvory", "RedLilac", "LemonYellow", "GreyOlive", "PearlBeige", "StoneGrey", "WineRed", "PearlOrange", "VioletBlue"];
    string[] thirdWords = ["Puppy", "Leopard", "Ram", "Cat", "Dog", "Deer", "Dingo", "Kangaroo", "Wombat", "Ape", "Kitten", "Whale", "Lion", "Bear", "Gorilla", "Yak", "Hedgehog", "Raccoon", "Seal", "Fox"];

    // pass the name of our NFTs token and its symbol
    constructor() ERC721 ("SquareNFT", "SQUARE") {
        console.log("This is my FIRST NFT contract. Gonna cry now!");
    }

    // randomly pick a word from each array
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
      // random generator
      uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
      // squash the # between 0 and the length of the array to avoid going out of bounds
      rand = rand % firstWords.length;
      return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
      uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
      rand = rand % thirdWords.length;
      return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
    }

    function getTotalNFTsMintedSoFar() public view returns (uint256) {
        return _tokenIds.current();
    }

    function makeAnEpicNFT() public {
      require(totalSupply > _tokenIds.current(), "All Nfts have been minted");

      // Get the current tokenId, starting at 0
      uint256 newItemId = _tokenIds.current();

      string memory first = pickRandomFirstWord(newItemId);
      string memory second = pickRandomSecondWord(newItemId);
      string memory third = pickRandomThirdWord(newItemId);
      string memory combinedWord = string(abi.encodePacked(first, second, third));

      string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

      // dynamically generate the metadata of the NFT
      string memory json = Base64.encode(
        bytes(
          string(
            abi.encodePacked(
              '{"name": "',
              // set the title of our NFT as the generated word.
              combinedWord,
              '", "description": "Just some random animals that lives in my dreams.", "image": "data:image/svg+xml;base64,',
              // add data:image/svg+xml;base64 and then append our base64 encode our svg.
              Base64.encode(bytes(finalSvg)),
              '"}'
            )
          )
        )
      );

      // prepend data:application/json;base64, to our data.
      string memory finalTokenUri = string(
          abi.encodePacked("data:application/json;base64,", json)
      );

      console.log("\n--------------------");
      console.log(finalTokenUri);
      console.log("--------------------\n");

      // Actually mint the NFT to the sender using msg.sender
      _safeMint(msg.sender, newItemId);

      // Set the NFTs data
      _setTokenURI(newItemId, finalTokenUri);

      // Increment the counter for when the next NFT is minted
      _tokenIds.increment();

      console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
      
      emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}