import os
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
from dotenv import load_dotenv

# Charger les variables d'environnement
load_dotenv()
# Configuration
STORAGE_ACCOUNT_NAME = os.environ.get("storage_account_name")  # Nom du compte de stockage
STORAGE_ACCOUNT_KEY = os.environ.get("storage_account_key")   # Clé d'accès du compte de stockage
CONTAINER_NAME = "mycontaineryankhoba"                     # Nom du conteneur

# Connexion au service Blob
connection_string = f"DefaultEndpointsProtocol=https;AccountName={STORAGE_ACCOUNT_NAME};AccountKey={STORAGE_ACCOUNT_KEY};EndpointSuffix=core.windows.net"
blob_service_client = BlobServiceClient.from_connection_string(connection_string)

# Fonction pour uploader un fichier (Create)
def upload_file(file_path, blob_name):
    blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=blob_name)
    with open(file_path, "rb") as data:
        blob_client.upload_blob(data)
    print(f"Fichier '{blob_name}' uploadé avec succès.")

# Fonction pour télécharger un fichier (Read)
def download_file(blob_name, download_path):
    blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=blob_name)
    with open(download_path, "wb") as download_file:
        download_file.write(blob_client.download_blob().readall())
    print(f"Fichier '{blob_name}' téléchargé vers '{download_path}'.")

# Fonction pour mettre à jour un fichier (Update)
def update_file(blob_name, new_file_path):
    blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=blob_name)
    with open(new_file_path, "rb") as data:
        blob_client.upload_blob(data, overwrite=True)
    print(f"Fichier '{blob_name}' mis à jour.")

# Fonction pour supprimer un fichier (Delete)
def delete_file(blob_name):
    blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=blob_name)
    blob_client.delete_blob()
    print(f"Fichier '{blob_name}' supprimé.")

# Fonction pour lister les fichiers dans le conteneur
def list_files():
    container_client = blob_service_client.get_container_client(CONTAINER_NAME)
    blobs_list = container_client.list_blobs()
    print("Fichiers dans le conteneur :")
    for blob in blobs_list:
        print(blob.name)

# Exemple d'utilisation
if __name__ == "__main__":
    # Uploader un fichier
    upload_file("example.txt", "example.txt")

    # Lister les fichiers
    list_files()

    # Télécharger un fichier
    download_file("example.txt", "downloaded_example.txt")

    # Mettre à jour un fichier
    update_file("example.txt", "updated_example.txt")

    # Supprimer un fichier
    # delete_file("example.txt")