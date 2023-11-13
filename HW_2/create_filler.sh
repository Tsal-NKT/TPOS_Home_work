docker rmi filler

docker build ./Filler -t filler:latest

docker run -it --rm --network ownNet --name filler filler
