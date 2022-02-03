import tensorflow.keras as keras
import numpy as np
import tensorflow as tf
import tensorflow_hub as hub
import tensorflow_text as text

if __name__ == "__main__":
    
    print("Model is loading ...")
    
    examples = [
        'this is such an amazing movie!',
        'The movie was great!',
        'The movie was meh.',
        'The movie was okish.',
        'The movie was terrible...'
    ]
    
    bert_model = tf.saved_model.load("./models/bert-sentiment")
    print("Model Loaded Successfully!")
    
    reloaded_results = bert_model(tf.constant(examples))
    print('Results from the saved model:')
    print(examples, reloaded_results)