npm install merkletreejs keccak256



import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

function verifyMerkleProof(
    bytes32[] calldata proof,
    bytes32 root,
    address recipient,
    uint256 amount
) public pure returns (bool) {
    // Reconstruct the leaf
    bytes32 leaf = keccak256(abi.encodePacked(recipient, amount));

    // Verify the proof against the Merkle Root
    return MerkleProof.verify(proof, root, leaf);
}
