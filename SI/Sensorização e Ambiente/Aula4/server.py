import requests
def runServer():
    f = open("LogTomTom.txt","w")
    while True:
        url = "https://api.tomtom.com/traffic/services/4/flowSegmentData/absolute/10/json?key=yHgC1YQO6lTzqz4UNm5nOXvpQezIiM21&point=52.41072,4.84239"
        
        # Making a GET request
        response = requests.get(url)
        # Checking if the request was successful (status code 200)
        if response.status_code == 200:
            f.write(str(response.text))
        else:
            print("Request failed with status code:", response.status_code)

def main():
    runServer()

if main() == "__main__":
    main()