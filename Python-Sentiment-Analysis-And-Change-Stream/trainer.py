import pandas as pd
from pymongo import MongoClient
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
from sklearn.model_selection import train_test_split


def read_mongo(
    db: str,
    col: str,
    uri: str
) -> pd.DataFrame:
    """Reads data from MongoDB using the given Database and Collection
    and returns a Pandas DataFrame.

    Args:
        db ([str]): Database name in MongoDB
        col (str): Collection name in MongoDB
        uri (str): URI of MongoDB Database

    Returns:
        pd.DataFrame: Pandas dataframe.
    """

    # Connecting to MongoDB
    client = MongoClient(
        uri
    )

    database = client[db]
    collection = database[col]
    df = pd.DataFrame(list(collection.find({}, {"_id": 0})))

    return df


def preprocessing(
    df: pd.DataFrame,
    vocab_size=40000,     # 40,000 unique words to train the network
    max_length=200,       # We will keep 200 words from each review
    trunc_type='post',    # truncated if review is bigger than 200 words
    oov_tok='<OOV>',      # substitutes unknown with <OOV>
):
    """Preprocess data received from mongodb. Function is not used anywhere but can be used for preprocessing for just the edge model.

    Args:
        df (pd.DataFrame): Dataframe for preprocessing
        vocab_size (int, optional): unique words to train the network. Defaults to 40000.
        max_length (int, optional): keep number of words from each review. Defaults to 200.
        trunc_type (str, optional): truncated if review is bigger than max_length words. Defaults to post.
        oov_tok (str, optional): substitutes unknown with <OOV>. Defaults to <OOV>.

    Returns:
        xTrain [list]: training sentences 
        xTest  [list]: testing sentences 
        yTrain [list]: training labels 
        yTest  [list]: training labels 
        word_index  [dict]: word index dictionary [str : int] 


    Args:
        df (pd.DataFrame): Dataframe for preprocessing

    Returns:
        xTrain [list]: training sentences 
        xTest  [list]: testing sentences 
        yTrain [list]: training labels 
        yTest  [list]: training labels 
        word_index  [dict]: word index dictionary [str : int] 
    """

    # Tokenizer
    tokenizer = Tokenizer(oov_token="<OOV>")

    # Splitting dataset as train and test
    train, test = train_test_split(df, test_size=0.2)

    train_reviews = train['text']
    train_labels = train['label']

    test_reviews = test['text']
    test_labels = test['label']

    # MongoDB has handled the string casting to make sure all data we
    # Receive are string formatted
    training_sentences = []
    for row in train_reviews:
        training_sentences.append(str(row))

    training_labels = []
    for row in train_labels:
        training_labels.append(int(row))

    testing_sentences = []
    for row in test_reviews:
        testing_sentences.append(str(row))

    testing_labels = []
    for row in test_labels:
        testing_labels.append(int(row))

    # Tokenizer
    tokenizer = Tokenizer(num_words=vocab_size, oov_token=oov_tok)

    # Fitting for training sentences
    tokenizer.fit_on_texts(training_sentences)

    # Getting word index
    word_index = tokenizer.word_index

    # Converting each word into integer and pads the sentence if necessary
    training_sequences = tokenizer.texts_to_sequences(training_sentences)
    training_padded = pad_sequences(
        training_sequences, maxlen=max_length
    )
    testing_sentences = tokenizer.texts_to_sequences(testing_sentences)
    testing_padded = pad_sequences(
        testing_sentences, maxlen=max_length
    )

    # print(len(training_padded), len(training_labels),
    #       len(testing_padded), len(testing_labels))

    # exit()

    return training_padded, testing_padded, training_labels, testing_labels, word_index
