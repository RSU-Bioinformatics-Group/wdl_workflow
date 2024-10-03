[![RSU Logo](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQmFd-EPn6jktivbaVRs2MKwPaHNYycBHS8r-Nwz3MNbwPhuuOCm9JBc0PzKISwCIPigA&usqp=CAU)](https://www.rsu.lv/en/bioinformatics-group)


# Getting started with containers: Docker and Singularity

Before getting started with WDL, it's recommended to familiarize yourself with Docker. If you're already comfortable with Docker, you can skip this step and proceed directly to working with WDL. 

**Link to the documentation -** https://medicalenvironment.github.io/docker-webpage/

# Server Access Instructions
**Log in to the RTU HPC Server**

   Open the Terminal on your local computer (or PowerShell for Windows) and log in to the RTU HPC server using your username and password:

   ```bash
   ssh <your_rtu_hpc_username>@ui-2.hpc.rtu.lv
   ```
   Replace `<your_rtu_hpc_username>` with the one provided by the RTU HPC team.

   You'll be prompted to enter your RTU HPC password:

   ```bash
   <your_rtu_hpc_username>@ui-2.hpc.rtu.lv's password: <your_rtu_hpc_password>
   ```
   Replace `<your_rtu_hpc_password>` with the password provided by the RTU HPC team.

# Setting Up Directory Paths in Configuration Files

After cloning this repository with the command `git clone <repository_url>`, ensure to replace the tilde (`~`) with your actual home directory or the specific directory paths in the JSON input file and Cromwell configuration file. This is crucial for correctly locating your container files and specifying where the output files should be written.

1. **fastqc_subworkflow_inputs.json**: Replace `~` with your home directory or the desired path.

2. **cromwell.conf**: Update any paths containing `~` with the actual directory paths.

Additionally, create and confirm that these directories exist and grant the necessary permissions for the workflow to function correctly:

To create the necessary directories:

```bash
mkdir output_data containers cromwell-executions cromwell-subworkflow-logs singularity_cache
```
To confirm that these directories exist and grant the necessary permissions

```bash
chmod 775 /path/to/output_data
chmod 775 /path/to/containers
chmod 775 /path/to/input_data
chmod 775 /path/to/cromwell-executions
chmod 775 /path/to/cromwell-subworkflow-logs
chmod 775 /path/to/singularity_cache
```

Or to simplify the command above you can enter this one:

```bash
chmod 775 /path/to/common_directory/{output_data,containers,input_data,cromwell-executions,cromwell-subworkflow-logs,singularity_cache}
```

**Important note**: Make sure that after creating the `~/containers` directory, you pull the Singularity image within this directory. Instructions will be provided further.

# Building WDL Workflows with Containers: A FastQC Example

This section introduces building WDL (Workflow Description Language) workflows with containerization, focusing on integrating the FastQC tool for quality control in sequencing data analysis. We demonstrate how to implement and run a containerized FastQC workflow on the RTU HPC, utilizing Docker and Singularity to maximize flexibility and portability.

**Authors:** Akbar Abayev, Baiba Vilne. RSU Bioinformatics Group

## ✨ Key Features

* **Reproducibility:** Singularity containers guarantee that your analysis runs the same way every time, no matter where you execute it.
* **Portability:** Easily share and deploy your QC workflow across various computing platforms.
* **Automation:** Cromwell handles the workflow execution, freeing you from manual intervention.
* **Customization:** Adapt input parameters to fit your specific data and analysis requirements.

## 📁 Directory Structure

*   
    *   `cromwell.conf`: Configuration settings for the Cromwell engine.
    *   `fastqc_subworkflow.wdl`: Defines the FastQC workflow steps and logic.
    *   `fastqc_subworkflow_inputs.json`: Example input parameters to get you started.
    *   `input_data`: Directory with the existing files.
    *   `output_data`: Directory for the output file after successfully execution the workflow.
    *   `cromwell-87.jar`: Cromwell engine used to run the workflow.
    *   `womtool-87.jar`: Tool created in order to test the workflow before processing necessary files.

## 🛠️ System Prerequisites 

Before diving in, make sure you have the following tools ready:

* **Installing Cromwell and WOMtool:** Use the `wget` command to download Cromwell and WOMtool `.jar` files. For example:

    ```bash
    wget https://github.com/broadinstitute/cromwell/releases/download/87/cromwell-87.jar
    ```
    ```bash
    wget https://github.com/broadinstitute/cromwell/releases/download/87/womtool-87.jar
    ```
    In this case, you’ve downloaded the cromwell-87.jar file into your current directory. [Here is the link](https://github.com/broadinstitute/cromwell/releases/download/87/cromwell-87.jar) to download the `.jar` file. The same process applies to the WOMtool installation [Link](https://github.com/broadinstitute/cromwell/releases/download/87/womtool-87.jar).
*   **RTU HPC account and familiarity with the environment:** [HPC User Manual - RTU HPC 2.6 documentation](https://hpc-guide.rtu.lv/)
*   **Docker:** (Optional) If you want to build your own FastQC image.
*   **Singularity:** v3.11.4 or later. Learn more about Singularity: [Introduction to Singularity Containers](https://bioinformaticsworkbook.org/Appendix/HPC/Containers/Intro_Singularity.html#gsc.tab=0)
*   **Java JDK:** v21.0.2 or compatible.
*   **WOMtool:** [Command line utilities for interacting with the Workflow Object Model (WOM)](https://cromwell.readthedocs.io/en/stable/WOMtool/)
*   **Cromwell:** An open-source workflow management system. 
    *   [Introduction to Cromwell](https://cromwell.readthedocs.io/en/stable/tutorials/FiveMinuteIntro/)
    *   [Cromwell Configuration for Singularity](https://cromwell.readthedocs.io/en/stable/getting_started/#using-singularity)

## 🚀 Getting Started

### 1. Load Modules

```bash
module avail
module load singularity/3.11.4 java/jdk-21.0.2
```

### 2. Pulling and converting Docker image into the Singularity format

At this stage it's recommended to check whether the (*.sif) image is located in the directory:
```bash
cd /path/to/containers
```

Pull the respective Docker image from the DockerHub and convert it into a Singularity format (*.sif):
```bash
singularity pull docker://biocontainers/fastqc:v0.11.9_cv8
```

If the user has created their own Docker image and it is located in a private repository and requires authentication, they need to provide the appropriate authentication credentials to Singularity. They can use Singularity's --docker-login option to provide Docker login credentials. For example:
```bash
export DOCKER_USERNAME=<your_docker_username> 
export DOCKER_PASSWORD=<your_docker_password> 
singularity pull --docker-login docker://<your_docker_username>/<docker_image_name> 
```

### 3. Important Note: 

Before running your Cromwell workflow, ensure the `cromwell.conf` and `fastqc_subworkflow_inputs.json` files are properly configured, especially regarding directory paths. 

**Permissions and Directory Verification:**

* **Input, Output, and Container Directories:** 
    * Verify the existence of all directories mentioned in the `cromwell.conf` and `fastqc_subworkflow_inputs.json` files, including input, output, and container directories.
    * Make sure these directories have the correct permissions: Read, Write, and Execute permissions are required.
    * Double-check that the specified paths within the configuration file are valid.
* **Missing Directories:**
    * If any directories are missing, create them with the necessary permissions.
* **Content Verification:**
    * Ensure the input directory contains the required files, such as FASTQ files for analysis.
    * The container directory should contain the relevant SIF image files.

**Workflow Files and Dependencies:**

It's recommended to include all necessary files and directories within your `wdl_workflow`. This includes:

* The workflow script itself.
* Any required input files (e.g., FASTQ files).
* Necessary container images (SIF files) for running the workflow.

By following these steps, you can ensure your Cromwell workflow has the proper configuration and resources to run successfully. 


### 4. Running WDL Workflows on RTU HPC

This section explains how to set up and run WDL (Workflow Description Language) workflows on the RTU HPC server, focusing on integrating the FastQC tool for quality control in sequencing data analysis. This setup leverages Docker and Singularity to maximize flexibility and portability.

### Prerequisites
- Ensure you have your RTU HPC username and password ready.
- Familiarize yourself with Docker and Singularity, as they will be used to containerize the workflow.

### Steps to Run the Workflow

1. **Navigate to Your Workflow Directory**

   After logging in, navigate to the directory where you would like to run the workflow (by default, you will be in your `/home` directory):

   ```bash
   cd path/to/your/workflow_directory
   ```
   Example:
   ```bash
   /mnt/beegfs2/home/<your_rtu_hpc_username>/wdl/wdl-tests
   ```

2. **Clone the WDL Workflow Repository**

   Use the `git clone` command followed by the URL of the repository. You can find the URL on the repository’s GitHub page by clicking the “Code” button and copying the URL.

   ```bash
   git clone https://github.com/RSU-Bioinformatics-Group/wdl_workflow.git
   ```

3. **Validate the WDL Script Using Womtool**

   Navigate to the WDL directory and validate the WDL script to ensure it is correctly formatted:

   ```bash
   java -jar womtool-87.jar validate fastqc_subworkflow.wdl
   ```

4. **Run the workflow**
   ```bash
   java -Dconfig.file=cromwell.conf -jar cromwell-87.jar run fastqc_subworkflow.wdl --inputs fastqc_subworkflow_inputs.json
   ```

If you encounter any issues related to the directories and permissions, please refer to the section **Setting Up Directory Paths in Configuration Files**.


### 5. FastQC Output
The FastQC workflow generates two types of output files:

1. **.zip File:** This is a compressed archive containing basic statistics and quality metrics about the sequence data. It includes files like `fastqc_data.txt` with detailed metrics and `summary.txt` with a quick overview. To view the content of the `.zip` file without extracting it, you can use the following command:
   ```bash
   zipinfo -1 filename.zip
   ```
   Replace `filename.zip` with the actual name of the `.zip` file.

2. **.html File:** This is a report file that provides a visual summary of the quality checks, which can be viewed in any web browser. To view the `.html` file using a text-based web browser, you can use `lynx` with the following command:
   ```bash
   lynx filename.html
   ```
   Replace `filename.html` with the actual name of the `.html` file.

To unzip the `.zip` file, use the following command in the terminal:
   ```bash
   unzip filename.zip
   ```
   Replace `filename.zip` with the actual name of the `.zip` file.


### What is WDL?

WDL (Workflow Description Language) is a language used to describe data processing workflows. It provides a way to specify tasks and their dependencies in a structured format, making it easier to automate and manage complex data analysis pipelines. WDL is often used with Cromwell, an open-source workflow management system that runs WDL scripts.

### Why Do We Need These Three Files?

1. **cromwell.conf**
   - **Purpose**: This file contains configuration settings for the Cromwell engine. It includes information such as backend configurations, database settings, and runtime options.
   - **Importance**: Proper configuration ensures that Cromwell can correctly execute workflows using the specified computational resources and settings.

2. **fastqc_subworkflow.wdl**
   - **Purpose**: This is the main WDL script that defines the sub-workflow for running FastQC. It specifies the tasks to be executed, the order in which they should be run, and the inputs/outputs for each task.
   - **Importance**: The WDL file is the core of the workflow, describing the steps and logic of the data processing pipeline. It allows for reproducibility and scalability of the analysis.

3. **fastqc_subworkflow_inputs.json**
   - **Purpose**: This JSON file provides the input parameters required by the WDL script. It includes paths to input data files, parameter values, and other necessary settings.
   - **Importance**: The inputs file makes the workflow flexible and reusable by allowing users to provide different input values without modifying the WDL script. It separates the workflow logic from the specific data and parameters used in each run.

These three files work together to ensure that the FastQC sub-workflow is properly defined, configured, and executed, providing a robust and reproducible data analysis pipeline.

### 🤔 Troubleshooting

If you run into any issues, verify the following:

*   **Modules:** Make sure the correct Singularity and Java modules are loaded.
*   **File Paths:** Double-check the paths in your `fastqc_workflow_inputs.json` file.
*   **Cromwell:** Review your Cromwell configuration for any errors.

For further assistance, consult the documentation for:
*   [Cromwell](https://cromwell.readthedocs.io/en/stable/)
*   [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)


## 🤝 Contributing

Your contributions are valued! Please open issues or submit pull requests to enhance this workflow.

In case of any questions/concerns my email address akbaba@rsu.lv and Head of the Bioinformatics group **Baiba Vilne** baiba.vilne@rsu.lv

Happy QC-ing! 🎉


