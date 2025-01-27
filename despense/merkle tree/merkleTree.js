const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

// Example recipient list and amounts
const recipients = [
  { address: '0x123...', amount: 100 },
  { address: '0x456...', amount: 200 },
  { address: '0x789...', amount: 300 },
];

// Create leaves by hashing the address and amount
const leaves = recipients.map(recipient =>
  keccak256(
    Buffer.from(
      recipient.address.slice(2) + recipient.amount.toString().padStart(64, '0'),
      'hex'
    )
  )
);

// Generate the Merkle Tree
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

// Get the Merkle Root (this will be submitted to your smart contract)
const root = tree.getHexRoot();
console.log('Merkle Root:', root);

// Generate a proof for a specific recipient
const recipientIndex = 0; // Index of the recipient in the list
const proof = tree.getHexProof(leaves[recipientIndex]);
console.log('Proof for recipient:', proof);

// You would provide `root` to the smart contract and use `proof` to verify claims.
