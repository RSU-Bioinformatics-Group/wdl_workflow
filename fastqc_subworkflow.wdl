# WDL script for performing QC on FastQ files using FastQC
version 1.0
# Script version v.0.2
# License: This project is licensed under the MIT License
#
# Define the workflow
workflow fastqc_subworkflow {
    # Input parameters
    input {
        # The directory where the data is stored
        String dataDir
        # An array of FASTQ file paths
        Array[String] fastqFiles
        # The directory where the output will be stored
        String outputDir
        # The Singularity image file for FastQC
        File imageFile
    }

    # Scatter operation to run FastQC on each FASTQ file in parallel
    scatter(file in fastqFiles) {
        # Call the task to run FastQC on each FASTQ file
        call runFastQC {
            input:
                # The Singularity image file provided by the user
                imageFile = imageFile,
                # The current FASTQ file from the scatter loop
                fastqFile = file,
                # The data directory
                dataDir = dataDir,
                # The output directory
                outputDir = outputDir
        }
    }

    # Output definitions
    output {
        # An array of output ZIP files containing the FastQC results
        Array[File] outputFiles1 = runFastQC.fastqcOutput1
        # An array of output HTML files containing the FastQC reports
        Array[File] outputFiles2 = runFastQC.fastqcOutput2
    }
}

# Define a task to run FastQC on a single FASTQ file
task runFastQC {
    # Input parameters
    input {
        # The Singularity image file for FastQC
        File imageFile
        # The input FASTQ file
        String fastqFile
        # The directory where the data is stored
        String dataDir
        # The directory where the output will be stored
        String outputDir
    }

    # Derive the base name of the FASTQ file without the extension
    String baseName = sub(fastqFile, "\\.(fastq|fq)(\\.gz|\\.bz2|\\.xz)?$", "")

    # Command to run FastQC using the Singularity image
    command {
        # Bind the data directory to the /data directory inside the container
        # Run FastQC on the input FASTQ file and output the results to the specified output directory
        # Bind the output directory
        singularity run -B ${dataDir}:/data -B ${outputDir}:/output ${imageFile} fastqc /data/${fastqFile} -o /output/
    }

    # Output definitions
    output {
        # The output ZIP file containing the FastQC results
        File fastqcOutput1 = "${outputDir}/${baseName}_fastqc.zip"
        # The output HTML file containing the FastQC report
        File fastqcOutput2 = "${outputDir}/${baseName}_fastqc.html"
    }
}
