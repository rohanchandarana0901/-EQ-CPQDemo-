(function() {
        'use strict';

        angular
            .module('wipro')
            .service('agreementService', agreementService);
    agreementService.$inject = ['$q', '$timeout'];

        /** @ngInject */
function agreementService($q, $timeout){
        var agreements = [
                {
                    'agreement_name': 'MSA Ahmd',
                    'status_category': 'In Effect',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'MSA',
                    'status_category': 'In Authoring',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'Inside Microprocessor',
                    'status_category': 'In Signatures',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'MSA Ahmd',
                    'status_category': 'In Effect',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'MSA',
                    'status_category': 'In Authoring',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'Inside Microprocessor',
                    'status_category': 'In Signatures',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'MSA Ahmd',
                    'status_category': 'In Effect',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'MSA',
                    'status_category': 'In Authoring',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'MSA',
                    'status_category': 'In Authoring',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'MSA',
                    'status_category': 'In Authoring',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'MSA',
                    'status_category': 'In Authoring',
                    'status': 'Contract',
                    'agreement_end_date': '20-08-2016'
                },
                {
                    'agreement_name': 'MSA',
                    'status_category': 'In Authoring',
                    'status': 'Author Contract',
                    'agreement_end_date': '04-08-2016'
                },
                {
                    'agreement_name': 'MSA',
                    'status_category': 'In Authoring',
                    'status': 'Author Contract',
                    'agreement_end_date': '20-09-2016'
                },
                {
                    'agreement_name': 'Inside Microprocessor',
                    'status_category': 'In Signatures',
                    'status': 'Pending',
                    'agreement_end_date': '11-08-2016'
                }];
    

        var internalActivity =[{
            'image_src': 'assets/images/img.png',
            'agreement_name': 'West Cost VPN 2016',
            'agreement_status': 'In Signature',
            'agreement_date': 'May 3,2016 12:30 PM EST'
        },
        {
            'image_src': 'assets/images/img.png',
            'agreement_name': 'West Cost VPN 2016',
            'agreement_status': 'In Authoring',
            'agreement_date': 'May 20,2016 12:30 PM EST'
        },
        {
            'image_src': 'assets/images/img.png',
            'agreement_name': 'West Cost VPN 2016',
            'agreement_status': 'In Authoring',
            'agreement_date': 'May 20,2016 12:30 PM EST'
        },
        {
            'image_src': 'assets/images/img.png',
            'agreement_name': 'West Cost VPN 2016',
            'agreement_status': 'In Authoring',
            'agreement_date': 'May 20,2016 12:30 PM EST'
        },
        {
            'image_src': 'assets/images/img.png',
            'agreement_name': 'West Cost VPN 2016',
            'agreement_status': 'In Authoring',
            'agreement_date': 'May 20,2016 12:30 PM EST'
        },
        {
            'image_src': 'assets/images/img.png',
            'agreement_name': 'West Cost VPN 2016',
            'agreement_status': 'In Authoring',
            'agreement_date': 'May 20,2016 12:30 PM EST'
        },
        {
            'image_src': 'assets/images/img.png',
            'agreement_name': 'West Cost VPN 2016',
            'agreement_status': 'In Signature',
            'agreement_date': 'May 3,2016 12:30 PM EST'
        },
        {
            'image_src': 'assets/images/img.png',
            'agreement_name': 'West Cost VPN 2016',
            'agreement_status': 'In Signature',
            'agreement_date': 'May 3,2016 12:30 PM EST'
        },
        {
            'image_src': 'assets/images/img.png',
            'agreement_name': 'West Cost VPN 2016',
            'agreement_status': 'In Signature',
            'agreement_date': 'May 3,2016 12:30 PM EST'
        }];
        
       

        
    var approvals =[{
            'action': 'Approve/Reject',
            'related_to': '000000132',
            'type': 'ABC',
            'approver': 'User1',
            'date': '4/5/2016 9:50 PM'
        },
        {
            'action': 'Approve/Reject',
            'related_to': '000000132',
            'type': 'PQR',
            'approver': 'User2',
            'date': '4/5/2016 9:50 PM'
        }]
        
     var tasks =[{
            'date': '4/5/2016 9:50 PM',
            'status': 'Pending',
            'subject': '000000132',
            'related': 'ABC',
            'account': 'A'
        },
        {
           'date': '4/15/2016 9:50 PM',
            'status': 'Approved',
            'subject': '000000002',
            'related': 'XYZ',
            'account': 'Z'
        }];
          function getAgreements(){
      
        var deferQ = $q.defer();
            $timeout(function() {
                deferQ.resolve(agreements);
            }, 400);
            return deferQ.promise;
        
    }
   
    function getActivity(){
        var deferQ = $q.defer();
            $timeout(function() {
                deferQ.resolve(internalActivity);
            }, 400);
            return deferQ.promise;
    } 
      
    function getApprovals(){
        var deferQ = $q.defer();
            $timeout(function() {
                deferQ.resolve(approvals);
            }, 400);
            return deferQ.promise;
    }
   
    function getTask(){
        var deferQ = $q.defer();
            $timeout(function() {
                deferQ.resolve(tasks);
            }, 400);
            return deferQ.promise;
    }

        
    var agreementService = {
        getAgreements : getAgreements,
        getTask : getTask,
        getActivity : getActivity,
        getApprovals : getApprovals
    }
    return agreementService;
    }

})();
