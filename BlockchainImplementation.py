import hashlib
import json
import os
import time


class Block:
    def __init__(self, block_number, previous_hash, data, nonce=None, block_hash=None, timestamp=None):
        self.block_number = block_number
        self.previous_hash = previous_hash
        self.data = data 
        self.nonce = nonce
        self.hash = block_hash
        self.timestamp = timestamp if timestamp is not None else time.time()

        if self.nonce is None or self.hash is None:  # If nonce and hash are not provided, mine them
            self.nonce, self.hash = self.mine_block()

    def mine_block(self):
        nonce = 0
        while True:
            block_contents = f"{self.block_number}{self.previous_hash}{json.dumps(self.data)}{self.timestamp}{nonce}".encode()
            block_hash = hashlib.sha256(block_contents).hexdigest()
            if block_hash[:4] == "0000":  # Hash condition with 4 leading zeroes
                return nonce, block_hash
            nonce += 1

    def to_dict(self):
        return {
            'block_number': self.block_number,
            'previous_hash': self.previous_hash,
            'data': self.data,  # Save the input data here
            'nonce': self.nonce,
            'hash': self.hash,
            'timestamp': self.timestamp  # Add timestamp in the block
        }

    def __str__(self):
        return (f"Block Number: {self.block_number}\n"
                f"Previous Hash: {self.previous_hash}\n"
                f"Data: {json.dumps(self.data, indent=4)}\n"
                f"Timestamp: {time.ctime(self.timestamp)}\n"
                f"Nonce: {self.nonce}\n"
                f"Hash: {self.hash}\n")


class Blockchain:
    def __init__(self, filename='5_BlockChain/blockchain.json'):
        self.filename = filename
        self.chain = self.load_chain()

    def load_chain(self):
        if os.path.exists(self.filename):
            with open(self.filename, 'r') as file:
                data = json.load(file)
                chain = []
                for block_data in data:
                    block = Block(
                        block_number=block_data['block_number'],
                        previous_hash=block_data['previous_hash'],
                        data=block_data['data'],
                        nonce=block_data['nonce'],
                        block_hash=block_data['hash'],
                        timestamp=block_data['timestamp']
                    )
                    chain.append(block)
                return chain
        else:
            genesis_block = Block(0, "0", {"Name": "Genesis Block", "Roll Number": "N/A", "Branch": "N/A"})
            return [genesis_block]


    def save_chain(self):
        with open(self.filename, 'w') as file:
            json.dump([block.to_dict() for block in self.chain], file, indent=4)

    def add_block(self, data):
        last_block = self.chain[-1]  
        new_block_number = last_block.block_number + 1  
        new_block = Block(new_block_number, last_block.hash, data)
        self.chain.append(new_block)
        self.save_chain()  
        print("\nBlock added successfully! Here is the new block:\n")
        print(new_block)

    def print_chain(self):
        for block in self.chain:
            print(block)


def get_user_data():
    name = input("Enter Name: ")
    roll_number = input("Enter Roll Number: ")
    branch = input("Enter Branch: ")
    return {"Name": name, "Roll Number": roll_number, "Branch": branch}


def switch_case(choice, blockchain):
    if choice == 1:
        data = get_user_data()  # Get user input for Name, Roll Number, and Branch
        blockchain.add_block(data)
    elif choice == 2:
        print("Displaying blockchain:\n")
        blockchain.print_chain()
    elif choice == 3:
        print("Exiting...")
        return False
    else:
        print("Invalid choice. Please select a valid option.")
    return True


if __name__ == "__main__":
    blockchain = Blockchain()

    while True:
        print("\n1. Add Block\n2. View Blockchain\n3. Exit")
        try:
            choice = int(input("Enter your choice: "))
            if not switch_case(choice, blockchain):
                break
        except ValueError:
            print("Please enter a valid integer choice.")
