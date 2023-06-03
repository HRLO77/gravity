import pickle
print('Doing...')
with open('./data.pickle', 'rb') as f:
    try:
        print('Please enter Ctrl^C')
        data = pickle.load(f)
    except BaseException as e:
        print(f'Error: {e}')
    print('doing...')
print('print...')
print(len(data))