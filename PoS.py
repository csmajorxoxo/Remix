import hashlib
import json
import os
import time
import random


class Block:
    def __init__(self, block_number, previous_hash, data, block_hash=None, timestamp=None, validator=None):
        self.block_number = block_number
        self.previous_hash = previous_hash
        self.data = data
        self.hash = block_hash
        self.timestamp = timestamp if timestamp is not None else time.time()
        self.validator = validator  # The user who validates this block

        if self.hash is None:  # If the hash is not provided, generate it
            self.hash = self.calculate_hash()

    def calculate_hash(self):
        block_contents = f"{self.block_number}{self.previous_hash}{json.dumps(self.data)}{self.timestamp}".encode()
        return hashlib.sha256(block_contents).hexdigest()

    def to_dict(self):
        return {
            'block_number': self.block_number,
            'previous_hash': self.previous_hash,
            'data': self.data,  # Save the input data here
            'hash': self.hash,
            'timestamp': self.timestamp,  # Add timestamp in the block
            'validator': self.validator  # Validator of the block
        }

    def __str__(self):
        return (f"Block Number: {self.block_number}\n"
                f"Previous Hash: {self.previous_hash}\n"
                f"Data: {json.dumps(self.data, indent=4)}\n"
                f"Timestamp: {time.ctime(self.timestamp)}\n"
                f"Hash: {self.hash}\n"
                f"Validator: {self.validator}\n")


class Blockchain:
    def __init__(self, filename='PoS_blockchain.json', stakes=None):
        self.filename = filename
        self.chain = self.load_chain()
        self.stakes = stakes if stakes is not None else {}

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
                        block_hash=block_data['hash'],
                        timestamp=block_data['timestamp'],
                        validator=block_data['validator']
                    )
                    chain.append(block)
                return chain
        else:
            genesis_block = Block(0, "0", {"Name": "Genesis Block", "Roll Number": "N/A", "Branch": "N/A"}, validator="system")
            return [genesis_block]

    def save_chain(self):
        with open(self.filename, 'w') as file:
            json.dump([block.to_dict() for block in self.chain], file, indent=4)

    def select_validator(self):
        """Select a validator based on stakes."""
        total_stake = sum(self.stakes.values())
        if total_stake == 0:
            raise ValueError("No stakes available for validator selection.")
        weighted_choice = random.choices(
            population=list(self.stakes.keys()),
            weights=list(self.stakes.values()),
            k=1
        )
        return weighted_choice[0]  # The selected validator

    def add_block(self, data):
        last_block = self.chain[-1]
        new_block_number = last_block.block_number + 1

        # Select validator based on stake
        validator = self.select_validator()

        new_block = Block(new_block_number, last_block.hash, data, validator=validator)
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
    # Example stakes: {"Alice": 50, "Bob": 30, "Charlie": 20}
    stakes = {
        "Alice": 50,
        "Bob": 30,
        "Charlie": 20
    }

    blockchain = Blockchain(stakes=stakes)

    while True:
        print("\n1. Add Block\n2. View Blockchain\n3. Exit")
        try:
            choice = int(input("Enter your choice: "))
            if not switch_case(choice, blockchain):
                break
        except ValueError:
            print("Please enter a valid integer choice.")