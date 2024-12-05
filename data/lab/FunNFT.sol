// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Make Fun with NFT
contract FunNFT is ERC721Enumerable, Ownable {
    // Counter for token IDs
    uint256 private _tokenIdCounter;

    // Base URI for metadata
    string private _baseTokenURI;

    // Mapping to check if a specific address is a minter
    mapping(address => bool) private _minters;

    // Event emitted when a new token is minted
    event Minted(address indexed to, uint256 indexed tokenId);

    constructor(string memory name, string memory symbol, string memory baseTokenURI)
        ERC721(name, symbol)
        Ownable(msg.sender)
    {
        _baseTokenURI = baseTokenURI;
        _minters[msg.sender] = true;
        _tokenIdCounter = 1;
    }

    // Function to set the base URI for metadata
    function setBaseURI(string memory baseTokenURI) external onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    // Function to mint new tokens, only callable by a minter
    function mint(address to, uint256 amount) external {
        require(_minters[msg.sender], "Caller is not a minter");

        for (uint256 i = 0; i < amount; i++) {
            _safeMint(to, _tokenIdCounter);
            emit Minted(to, _tokenIdCounter);
            _tokenIdCounter = _tokenIdCounter + 1;
        }
    }

    // Function to add a new minter, only callable by the contract owner
    function addMinter(address minter) external onlyOwner {
        _minters[minter] = true;
    }

    // Function to remove a minter, only callable by the contract owner
    function removeMinter(address minter) external onlyOwner {
        _minters[minter] = false;
    }

    // Function to check if an address is a minter
    function isMinter(address account) external view returns (bool) {
        return _minters[account];
    }

    // Override _baseURI to return the base URI for metadata
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    // Get base URI
    function baseURI() external view returns (string memory) {
        return _baseTokenURI;
    }

    // Get next token id
    function nextTokenId() external view returns (uint256) {
        return _tokenIdCounter;
    }
}
