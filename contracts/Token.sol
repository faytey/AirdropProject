//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FTTOKEN is ERC20 {
    bytes32 public merkleRoot;

    mapping(address => bool) public claimed;

    event Airdrop(address indexed recipient, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        bytes32 _merkleRoot
    ) ERC20(_name, _symbol) {
        _mint(address(this), _totalSupply);
        merkleRoot = _merkleRoot;
    }

    function airdrop(bytes32[] memory proof) public {
        require(!claimed[msg.sender], "Already claimed");
        // require(verifyProof(proof, merkleRoot, address(msg.sender)), "Invalid proof");
        claimed[msg.sender] = true;
        _mint(msg.sender, 1000);
        emit Airdrop(msg.sender, 1000);
    }

    function verifyProof(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) public pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}
