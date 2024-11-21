import hashlib

class Node:
    def __init__(self, left=None, right=None, value=None):
        self.left = left
        self.right = right
        self.value = value

def hashData(data):
    return hashlib.sha256(data.encode('utf-8')).hexdigest()

def combineHashes(left, right):
    combined = left + right
    return hashlib.sha256(bytes.fromhex(combined)).hexdigest()

def createTree(data):
    leaf_hashes = [hashData(item) for item in data]
    if len(leaf_hashes) == 0:
        raise ValueError("No leaf hashes provided")

    if len(leaf_hashes) == 1:
        return Node(value=leaf_hashes[0])

    current_level = [Node(value=h) for h in leaf_hashes]

    while len(current_level) > 1:
        next_level = []
        for i in range(0, len(current_level), 2):
            left = current_level[i]
            right = current_level[i + 1] if i + 1 < len(current_level) else left
            combined_hash = combineHashes(left.value, right.value)
            next_level.append(Node(left=left, right=right, value=combined_hash))
        current_level = next_level

    return current_level[0]

def verifyTree(root_hash, data):
    computed_root = createTree(data).value
    return computed_root == root_hash

def main():
    action = int(input("Generate/Verify (Enter 1/0): ").strip())
    
    if action == 1:
        num_blocks = int(input("Enter the number of blocks: "))
        data = [input(f"Enter data for block {i + 1}: ") for i in range(num_blocks)]
        root_node = createTree(data)
        print("Root hash:", root_node.value)
    
    elif action == 0:
        root_hash = input("Enter the root hash: ").strip()
        num_blocks = int(input("Enter the number of blocks: "))
        block_data = [input(f"Enter data for block {i + 1}: ") for i in range(num_blocks)]
        
        if verifyTree(root_hash, block_data):
            print("Verification successful. The root hash matches.")
        else:
            print("Verification failed. The root hash does not match.")
    
    else:
        print("Invalid action. Enter 1/0")

if __name__ == "__main__":
    main()
