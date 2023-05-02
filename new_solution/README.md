# DRS Ltd. Ghost Blog on Azure AKS

This project deploys a Ghost blog on Azure Kubernetes Service (AKS) using Terraform and Azure DevOps.

## Directory Structure

- `terraform/`: Contains the Terraform configuration files to create the AKS cluster.
- `kubernetes/`: Contains the Kubernetes manifests for the Ghost blog, service, and horizontal pod autoscaler.
- `azure-pipelines.yml`: Contains the Azure DevOps pipeline configuration for deploying the Ghost blog to AKS.

## Requirements

- Azure subscription
- Terraform
- Azure CLI
- Kubernetes CLI (kubectl)
- Azure DevOps account

## Deployment

1. Clone the repository and navigate to the `terraform/` directory.
2. Run `terraform init` to initialize the Terraform working directory.
3. Run `terraform apply` to create the AKS cluster.
4. Configure kubectl to connect to the AKS cluster using the `az aks get-credentials` command.
5. Update the `kubernetes/ghost-deployment.yaml` file with the appropriate values for your Ghost blog (e.g., domain, MySQL host, user, database).
6. Create an Azure DevOps project and import the repository.
7. Create a variable group in Azure DevOps called "AKS Connection" with a variable `aksServiceConnection` containing the Kubernetes service connection for the AKS cluster.
8. Configure the pipeline in Azure DevOps to use the azure-pipelines.yml file in the repository.
9. Run the pipeline to deploy the Ghost blog to the AKS cluster.

10. Once deployed, use the external IP address of the Ghost service to access the blog.

Maintenance and Development

To make changes to the Ghost blog configuration, update the relevant Kubernetes manifests in the kubernetes/ directory and commit the changes to the repository. The Azure DevOps pipeline will automatically deploy the changes to the AKS cluster.

For monitoring and debugging purposes, you can use Azure Monitor and Log Analytics to gain insights into your AKS cluster and applications.

Disaster Recovery

To ensure high availability and disaster recovery, consider creating a secondary AKS cluster in a different Azure region and configuring a multi-region load balancer, such as Azure Front Door, to route traffic between the two clusters. You can also configure Azure Site Recovery to replicate the Ghost blog's data and applications to the secondary region.

Serverless Function to Delete All Posts

To delete all posts at once using a serverless function, you can create an Azure Function using the Azure Functions service. The function will connect to your Ghost blog's MySQL database and delete all records in the posts table. Make sure to secure the function with appropriate authentication and authorization mechanisms to prevent unauthorized access.

Setting up the Azure Function

In the Azure portal, create a new Azure Functions App.
Choose the runtime stack (e.g., Node.js) and the operating system (e.g., Linux) for your function app.
Create a new function within the app using an HTTP trigger template.
Update the function code to connect to your MySQL database and delete all records in the posts table. You can use a MySQL client library (e.g., mysql2 for Node.js) to establish a connection and execute the DELETE statement.

const mysql = require('mysql2/promise');

module.exports = async function (context, req) {
    context.log('Deleting all posts.');

    const connectionConfig = {
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    };

    try {
        const connection = await mysql.createConnection(connectionConfig);
        await connection.query('DELETE FROM posts');
        await connection.end();

        context.res = {
            status: 200,
            body: 'All posts have been deleted.'
        };
    } catch (error) {
        context.log(error);
        context.res = {
            status: 500,
            body: 'An error occurred while deleting the posts.'
        };
    }
};


Add the necessary environment variables (e.g., DB_HOST, DB_USER, DB_PASSWORD, DB_NAME) in the function app settings.
Secure the function using authentication and authorization mechanisms such as Azure Active Directory, API keys, or function-level authentication.
Test the function by sending an HTTP request to its endpoint. The function should delete all the posts in the Ghost blog's MySQL database.

By following this guide, you have successfully deployed a highly available and scalable Ghost blog on Azure Kubernetes Service, and created a serverless function to delete all the posts at once. The solution is optimized for cost, and easy to maintain and develop in the future.



