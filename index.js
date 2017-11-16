'use strict';

console.log('Loading function');

var AWS = require('aws-sdk');
var sns = new AWS.SNS();

var rekognition = new AWS.Rekognition();

exports.handler = (event, context, callback) => {

    var nothingToDo = false;

    event.Records.forEach((record) => {
        // Kinesis data is base64 encoded so decode here
        console.log('Kinesis data length: ' + record.kinesis.data.length);
        const payload = new Buffer(record.kinesis.data, 'base64');
        console.log('Payload length: ' + payload.length);
        var labelParams = {
            Image: {
                Bytes: payload
            },
            MaxLabels: 100,
            MinConfidence: 95
        };

        var faceDetectParams = {
            Attributes: ['ALL'],
            Image: {
                Bytes: payload
            }
        };

        console.log('calling rekognition');
        rekognition.detectLabels(labelParams, function (err, data) {

            if (err) console.log(err, err.stack); // an error occurred
            else {
                console.log('called rekognition');
                var now = new Date();
                var dateString = now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + now.getDay() + ' ' + now.getHours() + ':' + now.getMinutes() + ':' + now.getSeconds();

                console.log('Labels: ' + data.Labels.length);

                if (data.Labels.length === 0) { nothingToDo = true; }
                var connected = false;
                var connection = null;
                var labels = '';

                rekognition.detectFaces(faceDetectParams, function (faceerr, facedata) {
                    if (faceerr) console.log(faceerr);
                    console.log('faces:');
                    console.log(facedata.FaceDetails.length);



                    for (var labelNum in data.Labels) {
                        var label = data.Labels[labelNum];
                        labels += label.Name + '; ';
                        console.log(label);
                    }

                    for (var faceNum in facedata.FaceDetails) {
                        console.log('facenum: ' + faceNum);
                        if (facedata.FaceDetails[faceNum].Smile.Value === true) {
                            labels += 'Happy Person; ';
                        }
                        //console.log('face: ' + JSON.stringify(facedata.FaceDetails[faceNum].AgeRange));
                    }

                    var snsparams = {
                        Message: labels,
                        TopicArn: process.env.SNSTopicName
                    };

                    sns.publish(snsparams, function (err, data) {
                        if (err) {
                            console.error('error publishing to SNS');
                            console.log(err);
                        } else {
                            console.info('message published to SNS');
                        }


                    });

                });
            }
        });
    });

    console.log('about to call back');

    callback(null, `Successfully processed ${event.Records.length} records.`);
};