// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// https://book.getfoundry.sh/tutorials/solmate-nft
// https://github.com/FredCoen/nft-tutorial

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

error InvalidSupply();
error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();
error NoBalanceToWithdraw();

contract ERC721Token is ERC721, Ownable {
    using Strings for uint256;

    string public baseURI;
    uint256 public currentTokenId;
    uint256 public mint_price;
    uint256 public immutable total_supply;

    event BaseURIChanged(string indexed from, string indexed to);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        address _owner,
        uint256 _mint_price,
        uint256 _total_supply
    ) ERC721(_name, _symbol) Ownable(_owner) {
        baseURI = _baseURI;
        mint_price = _mint_price;
        if (_total_supply <= 0) {
            revert InvalidSupply();
        }
        total_supply = _total_supply;
    }

    function mintTo(address recipient) public payable returns (uint256) {
        if (msg.value != mint_price) {
            revert MintPriceNotPaid();
        }
        uint256 newTokenId = currentTokenId + 1;
        if (newTokenId > total_supply) {
            revert MaxSupply();
        }
        currentTokenId = newTokenId;
        _safeMint(recipient, newTokenId);
        return newTokenId;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        emit BaseURIChanged(baseURI, _newBaseURI);
        baseURI = _newBaseURI;
    }

    function withdrawPayments(address payable payee) external onlyOwner {
        if (address(this).balance == 0) {
            revert NoBalanceToWithdraw();
        }

        payable(payee).transfer(address(this).balance);
    }

    function _checkOwner() internal view override {
        require(msg.sender == owner(), "Ownable: caller is not the owner");
    }
}
