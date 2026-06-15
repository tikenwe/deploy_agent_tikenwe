# deploy_agent_tikenwe

## How to Run the Script

1. Clone the repository and navigate into it:
   git clone https://github.com/tikenwe/deploy_agent_tikenwe.git
   cd deploy_agent_tikenwe

2. Make the script executable:
   chmod +x setup_project.sh

3. Run the script:
   bash setup_project.sh

4. When prompted, enter a project name e.g. v1

5. Choose whether to update the attendance thresholds yes or no

## How to Trigger the Archive Feature

While the script is running, press Ctrl+C at any prompt after entering the project name. The script will:
- Catch the SIGINT signal
- Bundle the incomplete project directory into a .tar.gz archive named attendance_tracker_input_archive.tar.gz
- Delete the incomplete directory to keep the workspace clean
Video link: (....)
