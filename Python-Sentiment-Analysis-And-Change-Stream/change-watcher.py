import re
from pymongo import MongoClient
import tensorflow.keras as keras
import pymongo
import numpy as np
import tensorflow as tf
import tensorflow_hub as hub
import tensorflow_text as text
from bson.objectid import ObjectId


def changeStreamWatcher(
    uri, 
    db, 
    col
    ):
    """Watch for changes in given collection. This is a process that will keep running. Do not close terminal

    Args:
        uri (str): URI of mongoDB atlas cluster
        db (str): Database name
        col (str): Collection name
    """
    # Connecting to MongoDB
    client = MongoClient(
        uri
    )

    # Database
    database = client[db]
    
    # Collection
    collection = database[col]
    
    # Loading BERT model
    bert_model = tf.saved_model.load("./models/bert-sentiment")
    
    # Watch for inserts or updates to the collection
    pipeline = [
        {
        '$match': {
            'operationType': { '$in': ['insert', 'update'] }
        }
    }]
    
    # Watch changes in collection 
    try:
        with collection.watch(full_document='updateLookup', pipeline=pipeline) as stream:
            for insert_change in stream:
                document = insert_change["fullDocument"]
                review = document['review']
                print(document)
                bert_model_results = bert_model(tf.constant([review]))
                print("Score: ", bert_model_results.numpy()[0][0].item())
                print("Score: ", type(bert_model_results.numpy()[0][0].item()))
                document['sentiment_score'] = bert_model_results.numpy()[0][0].item()
                collection.replace_one({'_id' : document['_id']}, document, upsert=True)
                
    except KeyboardInterrupt:
            print("Interrupting program...")
            exit()
    except pymongo.errors.PyMongoError as error:
        print(error)
        exit()

if __name__ == "__main__":
    username = "" # Enter username
    password = "" # Enter password
    uri = f"mongodb+srv://{username}:{password}@" # Insert MongoDB URI
    DATABASE = "Sentiment"
    COLLECTION = "Movie"
    
    # Listen to changes
    changeStreamWatcher(uri, DATABASE, COLLECTION)