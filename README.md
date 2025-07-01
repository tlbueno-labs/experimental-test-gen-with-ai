# experimental-test-gen-with-ai

Experimental project to use AI to generate test cases and test implementations

On this project we will use the AI model to generate test cases and implementations for the [Butane](https://coreos.github.io/butane/) tool using the [TMT](https://tmt.readthedocs.io/en/stable/) tool.

The files on this repository are the results of the experiment to generate test cases and implementations using the AI model. They are not meant to be used as is, but as a demonstration about what can be generated.

## Requirements

### Tools

- [podman](https://podman.io)

### Expected knowledge (basic knowledge is enough)

- [podman](https://podman.io)
- [butane](https://coreos.github.io/butane/)
- [tmt](https://tmt.readthedocs.io/en/stable/)
- [goose](https://block.github.io/goose/)

## Setup the environment

### Commands in the host

Create the directory to work on

```shell
mkdir -p ${HOME}/experimental-test-gen-with-ai
```

Create the container to work on using `${HOME}/experimental-test-gen-with-ai` directory mapped to container `/experimental-test-gen-with-ai` directory.

```shell
podman run --rm -it --name experimental-test-gen-with-ai --volume ${HOME}/experimental-test-gen-with-ai:/experimental-test-gen-with-ai:Z --workdir /experimental-test-gen-with-ai fedora:latest
```

Once executed, you should be be inside the container with the `/experimental-test-gen-with-ai` directory mapped to your host. Follow up with the section below [Command in the container](#commands-in-the-container) to continue the setup.

### Commands in the container

Install the required packages in the container

```shell
dnf install --assumeyes butane tmt libxcb
```

Install goose

```shell
curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | CONFIGURE=false bash
```

Configure goose to use the Google Gemini model by setting the environment variables. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual Google Gemini API key.

```shell
export GOOSE_PROVIDER="google"
export GOOSE_MODEL="gemini-2.5-flash"
export GOOGLE_API_KEY="YOUR_GEMINI_API_KEY_HERE"
```

Start goose session with the built-in extensions.

```shell
goose session --with-builtin "developer,computercontroller,memory,tutorial"
```

Once executed, you should see a message indicating that the session has started and you can start interacting with the AI model in the session shell.

## Generating stories, test cases and implementations

To generate the test cases and implementations, you will interact with the AI model using prompts. Below are the prompts to start the process.

### Prompt 01

```text
You will act as a senior quality engineer. Your role is to create the test cases and implement them for the butane tool.
It will be function black box testing based on the tool commands. The implementation will use the TMT testing tool.
As the TMT tool also supports stories for document test cases, it must be used for the test case generation allowing the documentation and implementation to remain in the same place.
The tests should contain happy paths, corner cases and any additional scenarios that may be needed for a complete functionality test.

References:

TMT tool docs on web: [tmt docs](https://tmt.readthedocs.io/en/stable)
TMT tool stories docs on web: [tmt stories docs](https://tmt.readthedocs.io/en/stable/spec/stories.html)
butane executable: /usr/bin/butane
tmt executable: /usr/bin/tmt

Additional info:

- Review the TMT documentation to understand how to create the stories, test cases and implement them.
- For butane configuration always use fcos variant.
- Use the /experimental-test-gen-with-ai/tmt directory as the base directory for any artifacts.
- The test artifacts structure must be:
  - tmt/features/feature-name, where feature-name is the feature name, like output for the output parameter.
  - tmt/features/feature-name/stories for the test case stories related to the feature
  - tmt/features/feature-name/tests for the tmt tests implementations
  - tmt/plans for plans that are common for all features
  - tmt/tests for tests that are common for all features
- butane tool and tmt tool are already installed in the host
- If you need additional tools or any additional needs, let me know and I will provide you.
- To avoid rate limit to query any resource outside, slow down your queries, specially when interacting with external AI/LLM
- Add as much comments as needed in the files that you generate
- TMT .fmf files are yaml files, so format it as yaml
- Stories files must have the contents:
  - story
  - description
  - example, it must contain only the description of a possible steps not an command or implementation
  - tag, always prefix the feature name tag with `feature-`. Create additional tags as needed, like `happy-path`, `corner-case`, `error-case`, etc.
  - tier. tier 0 for basic smoke tests, tier 1 for more complex tests, tier 2 for corner cases and error cases.
- For each test implementation that will be generated, create a directory for with with the test name and inside it create the `test.fmf` file with the test metadata and the `test.sh` file with the test implementation.
- The test implementation must be in bash script and use the butane tool to run the tests
As the 1st step, start with the test cases only as stories for the parameters --output only.
After the generation of the cases I will provide the next steps.
```

After a successful execution of the above prompt, you should see the generated stories `/experimental-test-gen-with-ai/tmt/features/output/stories` directory. Then, you can proceed with the next prompt to generate the test plan and test implementation.

### Prompt 02

```text
As next step take the stories that you generated and generate the tmt tool test plan and test implementation to all test cases.
```

After executing the above prompt, you should see the generated test plan in `/experimental-test-gen-with-ai/tmt/plans` and the test implementations in `/experimental-test-gen-with-ai/tmt/features/output/tests`.


## Demo

![Demo](demo.gif "Demo of the test generation process")

## Conclusion

In this document, we have outlined the process of generating test cases and implementations using the TMT tool in conjunction with the Butane tool. By following the prompts and utilizing the AI model, you can create a comprehensive set of tests that cover various scenarios for features.

The generated stories, test plans, and test implementations provide a good foundation for ensuring the quality and reliability of software.
Make sure to review the generated files and adapt them as necessary to fit your specific requirements and testing needs. You can also extend the prompts to cover additional features or parameters as needed.
On this experiment I could see that the AI model is capable of generating meaningful test cases and implementations based on the provided prompts, but it may require some manual adjustments to ensure the tests are comprehensive and cover all edge cases. Also, the AI may not always follow the exact structure or requirements specified in the prompts, so it's important to review and refine the generated content as needed. On this experiment I used the free tier of the Google Gemini model, which has some limitations in terms of response length and complexity. For more complex scenarios or larger test suites, you may need to consider using a paid tier or a different AI model that can handle larger requests and provide more detailed responses or a customized model trained specifically for your testing needs.
