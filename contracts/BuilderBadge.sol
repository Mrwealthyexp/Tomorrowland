// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/// @title Tomorrowland Builder Badge (BLDR)
/// @notice Free soulbound ERC-721 badge on Polygon. One badge per wallet.
contract BuilderBadge is ERC721Enumerable, Ownable {
    error ZeroAddress();
    error AlreadyBadged(address wallet);
    error Soulbound();
    error BurnDisabled();

    event BaseURISet(string newBaseURI);
    event BadgeMinted(address indexed to, uint256 indexed tokenId, address indexed operator);
    event AirdropCompleted(uint256 recipientCount);

    uint256 private _nextTokenId = 1;
    string private _baseTokenURI;

    constructor(string memory baseTokenURI_) ERC721("Tomorrowland Builder Badge", "BLDR") Ownable(msg.sender) {
        _baseTokenURI = baseTokenURI_;
    }

    /// @notice Public free mint. Each wallet can hold at most one badge.
    function safeMint(address to) external {
        _mintBadge(to);
    }

    /// @notice Owner-only badge distribution for pioneers.
    function airdrop(address[] calldata recipients) external onlyOwner {
        uint256 len = recipients.length;
        for (uint256 i = 0; i < len; i++) {
            _mintBadge(recipients[i]);
        }
        emit AirdropCompleted(len);
    }

    /// @notice Owner can update metadata base URI.
    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
        emit BaseURISet(newBaseURI);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function _mintBadge(address to) internal {
        if (to == address(0)) revert ZeroAddress();
        if (balanceOf(to) != 0) revert AlreadyBadged(to);

        uint256 tokenId = _nextTokenId;
        _nextTokenId = tokenId + 1;
        _safeMint(to, tokenId);

        emit BadgeMinted(to, tokenId, msg.sender);
    }

    /// @dev Allow mint-only state changes in `_update` and block transfer/burn.
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        address from = _ownerOf(tokenId);

        if (from != address(0)) {
            if (to == address(0)) revert BurnDisabled();
            revert Soulbound();
        }

        return super._update(to, tokenId, auth);
    }

    function approve(address, uint256) public pure override {
        revert Soulbound();
    }

    function setApprovalForAll(address, bool) public pure override {
        revert Soulbound();
    }

    function transferFrom(address, address, uint256) public pure override {
        revert Soulbound();
    }

    function safeTransferFrom(address, address, uint256) public pure override {
        revert Soulbound();
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public pure override {
        revert Soulbound();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
