from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.backends import default_backend
import hashlib
import os
import base64

def generate_keys():
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )
    public_key = private_key.public_key()
    
    with open("private_key.pem", "wb") as private_file:
        private_file.write(private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ))

    with open("public_key.pem", "wb") as public_file:
        public_file.write(public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        ))
    
    return private_key, public_key

def load_keys():
    with open("private_key.pem", "rb") as private_file:
        private_key = serialization.load_pem_private_key(
            private_file.read(),
            password=None,
            backend=default_backend()
        )

    with open("public_key.pem", "rb") as public_file:
        public_key = serialization.load_pem_public_key(
            public_file.read(),
            backend=default_backend()
        )

    return private_key, public_key

def generate_digital_signature(message_path, private_key):
   
    with open(message_path, 'r') as file:
        data = file.read()
    
    message_digest = hashlib.sha256(data.encode()).hexdigest()

    concatenated_data = data + message_digest
    
    signature = private_key.sign(
        concatenated_data.encode('utf-8'),
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )

    with open("signature.bin", 'wb') as signature_file:
        signature_file.write(concatenated_data.encode('utf-8') + signature)
    
    print("\nDigital Signature saved to 'signature.bin'.")
    return base64.b64encode(signature).decode('utf-8')

def verify_digital_signature(signature_file_path, public_key):
    try:
        with open(signature_file_path, 'rb') as file:
            content = file.read()

        key_size = 2048 // 8 
        concatenated_data = content[:-key_size]  
        signature = content[-key_size:]  
        
        message = concatenated_data[:-64].decode('utf-8')  
        message_digest = concatenated_data[-64:].decode('utf-8') 
        
        recomputed_digest = hashlib.sha256(message.encode()).hexdigest()

        if recomputed_digest != message_digest:
            print("\nVerification failed: The message digest does not match.")
            return False
        
        public_key.verify(
            signature,
            concatenated_data,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        print("\nVerification successful: The signature is valid.")
        return True
        
    except Exception as e:
        print(f"\nVerification failed: {str(e)}")
        return False

def main():
    if not os.path.exists("private_key.pem") or not os.path.exists("public_key.pem"):
        private_key, public_key = generate_keys()
        print("Keys generated and saved to bin files.")
    else:
        private_key, public_key = load_keys()
        print("Keys loaded from bin files.")
    
    while True:
        choice = input("\n1. Generate Digital Signature\n2. Verify Digital Signature\n3. Exit\nEnter your choice: ")
        
        if choice == '1':
            message_path = input("Enter the path to the message txt file: ")
            if not os.path.exists(message_path):
                print("Message file does not exist.")
                continue
            signature = generate_digital_signature(message_path, private_key)
            print(f"\nDigital Signature Generated Successfully!\nSignature: {signature}")
        
        elif choice == '2':
            signature_file_path = input("Enter the path to the digital signature binary file: ")
            if not os.path.exists(signature_file_path):
                print("Signature file does not exist.")
                continue
            verify_digital_signature(signature_file_path, public_key)
        
        elif choice == '3':
            print("Exiting...")
            break
        
        else:
            print("Invalid choice! Please try again.")

if __name__ == "__main__":
    main()
