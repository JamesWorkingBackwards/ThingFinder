# ThingFinder
ThingFinder streams video from iOS via Kinesis to Lambda and Rekognition then texts you back what it sees. KCaster is the iOS client which uses the AWS SDK for iOS. Compiles under XCode 9.1/tested under iOS 11. First run the CloudFormation script (template.yaml) in your AWS account, then copy-paste the ID of the created Cognito user pool and the name of the created Kinesis stream into the indicated places in the KCaster source before compiling.
