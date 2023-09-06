import subprocess
import json

termination_msg = "SpotInstanceInterruption"


def call_dx(command: str) -> str:
    print(f'Running command: {command}')
    process = subprocess.run(command, stdout=subprocess.PIPE, shell=True, check=True)
    output = process.stdout.decode("utf-8")
    print(f'Command output: {output}')
    return output


def fetch_failed_jobs():
    jobs_json = call_dx('dx find jobs --json --state failed --created-after=-2d --num-results 1000')
    return json.loads(jobs_json)


def extract_failed_job_names(jobs):
    job_names = []
    unique_jobs = []

    for job in jobs:
        failure_reason = job.get('failureReason', '')
        if failure_reason == termination_msg:
            job_name = job.get('name')
            job_id = job['id']
            if job_name not in job_names:
                job_names.append(job_name)
                unique_jobs.append(job_id)
                print(f'Found failed job with ID: {job_id} and failureReason: {failure_reason}')

    return unique_jobs


def restart_failed_jobs(jobs):
    for job_id in jobs:
        print(f'Restarting job {job_id}')
        job_description_json = call_dx(f'dx describe {job_id} --verbose --json')
        job_description = json.loads(job_description_json)
        run_inputs = job_description["runInput"]
        cmd = (
            f'dx run saige-universal-step-2 '
            f'-i output_prefix="{run_inputs["output_prefix"]}" '
            f'-i model_file="{run_inputs["model_file"]["$dnanexus_link"]["id"]}" '
            f'-i variance_ratio="{run_inputs["variance_ratio"]["$dnanexus_link"]["id"]}" '
            f'-i chrom="{run_inputs["chrom"]}" '
            f'-i group_file="{run_inputs["group_file"]["$dnanexus_link"]["id"]}" '
            f'-i annotations="{run_inputs["annotations"]}" '
            f'-i test_type="{run_inputs["test_type"]}" '
            f'-i exome_bed="{run_inputs["exome_bed"]["$dnanexus_link"]["id"]}" '
            f'-i exome_bim="{run_inputs["exome_bim"]["$dnanexus_link"]["id"]}" '
            f'-i exome_fam="{run_inputs["exome_fam"]["$dnanexus_link"]["id"]}" '
            f'-i GRM="{run_inputs["GRM"]["$dnanexus_link"]["id"]}" '
            f'-i GRM_samples="{run_inputs["GRM_samples"]["$dnanexus_link"]["id"]}" '
            f'--instance-type "mem3_ssd1_v2_x8" --priority low --destination /brava/outputs/step2/ -y --name "{job_description["name"]}"'
        )
        call_dx(cmd)


def main():
    print('Fetching failed jobs...')
    jobs = fetch_failed_jobs()
    print(f'Total failed jobs found: {len(jobs)}')

    print('Extracting unique failed jobs...')
    unique_jobs = extract_failed_job_names(jobs)
    print(f'Total unique failed jobs found: {len(unique_jobs)}')

    print('Restarting failed jobs...')
    restart_failed_jobs(unique_jobs)
    print('Job restarting finished.')


if __name__ == "__main__":
    main()
