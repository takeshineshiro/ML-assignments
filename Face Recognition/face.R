library (pixmap)

# List the train files
trainFiles = dir("orl_faces", pattern="*[1-9].pgm", full.names=T, recursive=T)

# List the test files
testFiles = dir("orl_faces", pattern="*10.pgm", full.names=T, recursive=T)

# Separate the training set and test set corresponding to each folder
trainSet = numeric(9)
testSet  = 1
x <- 1:40
for (i in seq(along = x))
{
  searchStr = paste('/s', i, '/', sep='')
  trainSet  = rbind(trainSet, trainFiles[grep(searchStr, trainFiles)])
  testSet   = rbind(testSet, testFiles[grep(searchStr, testFiles)])
}
trainSet = trainSet[2:nrow(trainSet),]
testSet  = testSet[2:nrow(testSet),]

# Create the training and test matrix of row vectors of pixels
trainMatrix = numeric(92 * 112)
testMatrix  = numeric(92 * 112)
y <- 1:9
for (i in seq(along = x))
{
  for (j in seq(along = y))
  {
    t <- read.pnm(trainSet[i,j])
    m <- getChannels(t)
    trainMatrix = rbind(trainMatrix, as.vector(m))
  }
  t <- read.pnm(testSet[i])
  m <- getChannels(t)
  testMatrix = rbind(testMatrix, as.vector(m))
}

trainMatrix = trainMatrix[2:nrow(trainMatrix),]
testMatrix  = testMatrix[2:nrow(testMatrix),]

# Compute variance of trainMatrix and removing rows that have low variance
varianceMat = numeric (ncol(trainMatrix))
x <- 1:ncol(trainMatrix)
for (i in seq(along=x))
{
  varianceMat[i] = var(trainMatrix[,i])
}
keepCols = varianceMat > 0.04152 # Manually obtained value
#trainMatrix = trainMatrix[, keepCols]
#testMatrix  = testMatrix[, keepCols]

# Mean vector
trainMeanVector = colMeans (trainMatrix)

# PCA
principalComp = prcomp (trainMatrix)
eigenVals = principalComp$sdev
eigenVectors = principalComp$rotation
#x <- 1:360
#s = 0
#total = sum(eigenVals * eigenVals)

#for (k in seq(along=x))
#{
#  s = s + (eigenVals[k] * eigenVals[k])
#  if (s / total > 0.9)
#  {
#    break
#  }
#}
c = 1:nrow(newTestSamples)
accuracy = numeric( (360 - 10) / 10)
for (k in seq(10, 360, 10))
{
  U = eigenVectors[,1:k]

  # Project both the training samples and test samples on the new dimensional space.
  newTrainSamples = (trainMatrix - trainMeanVector) %*% U
  newTestSamples  = (testMatrix  - trainMeanVector) %*% U

  y <- 1:nrow(newTrainSamples)
  x <- 1:nrow(newTestSamples)
  predicted = numeric (nrow(newTestSamples))
  for (i in seq(along=x))
  {
    minDist = Inf
    minIndex = -1
    for (j in seq(along=y))
    {
      distance = dist(rbind(newTrainSamples[j,], newTestSamples[i,]))[1]
      if (distance < minDist)
      {
        minDist = distance
        minIndex = j
      }
    }
    predicted[i] = ceiling(minIndex / 9)
  }

  accuracy[k/10] = (sum (predicted == c) / 40)
  img = pixmap(newTrainSamples[i,], nrow=92, ncol=112)
}

print(accuracy)
