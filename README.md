# DecentraPub - Decentralized Scientific Paper Repository

DecentraPub is a blockchain-based platform designed to manage and store scientific publications securely. Built on the Stacks blockchain using Clarity smart contracts, it ensures authorship integrity, immutability, and controlled access to academic research.

## Features

- **Register Publications**: Authors can register their research papers with metadata, ensuring authenticity and timestamped proof of ownership.
- **Modify Publications**: Authors can update details like title, summary, and tags while keeping track of changes.
- **Transfer Ownership**: Ownership of a publication can be transferred securely to another user.
- **Access Control**: View permissions can be assigned to specific users for restricted access to research papers.
- **Immutability & Security**: All transactions are recorded on the blockchain, preventing unauthorized modifications.

## Smart Contract Overview

The Clarity smart contract defines:
- **Storage Structures**: Keeps track of registered publications and their metadata.
- **Permission Management**: Controls who can access a given publication.
- **Validation Functions**: Ensures data integrity by checking title length, byte size, and tag validity.
- **Publication Functions**: Allows users to register, modify, delete, and transfer publications securely.

### Error Codes

| Code | Description |
|------|-------------|
| `u300` | Owner required |
| `u301` | Publication missing |
| `u302` | Publication already exists |
| `u303` | Invalid publication details |
| `u304` | Publication size constraints violated |
| `u305` | Unauthorized action |

## Installation & Deployment

1. **Prerequisites**
   - Install [Clarity](https://docs.stacks.co/docs/clarity)
   - Set up a local Stacks blockchain environment

2. **Clone the Repository**
   ```sh
   git clone https://github.com/yourusername/decentra-pub.git
   cd decentra-pub
   ```

3. **Deploy the Contract**
   ```sh
   clarity-cli check contracts/decentra-pub.clar
   clarity-cli launch contracts/decentra-pub.clar
   ```

## Usage

- **Register a Publication**
  ```clarity
  (contract-call? .decentra-pub register-publication "Title" 1024 "Summary" ["Blockchain", "Decentralized"])
  ```

- **Modify a Publication**
  ```clarity
  (contract-call? .decentra-pub modify-publication u1 "Updated Title" 2048 "Updated Summary" ["Research", "Web3"])
  ```

- **Transfer Ownership**
  ```clarity
  (contract-call? .decentra-pub transfer-publication u1 tx-sender)
  ```

## Roadmap

- Implement **encrypted file storage** for actual paper content.
- Add **peer review and citation tracking**.
- Develop a **frontend DApp** for easy interaction.

## License

This project is licensed under the MIT License.
