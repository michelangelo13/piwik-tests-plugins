<?php

class InspectionProblem
{
    private $file;
    private $line;
    private $description;

    public function __construct(DOMNode $node)
    {
        $this->file = $this->getChildNodeValue($node, 'file');
        $this->line = $this->getChildNodeValue($node, 'line');
        $this->description = $this->getChildNodeValue($node, 'description');
    }

    public function printOut()
    {
        echo $this->getRelativeFilePath() . " at line " . $this->line . " -> " . $this->description . "\n";
    }

    public function getRelativeFilePath()
    {
        return str_replace('file://$PROJECT_DIR$/', '', $this->file);
    }

    public function getChildNodeValue(DOMNode $node, $nodeName)
    {
        for ($i = 0; $i < $node->childNodes->length; ++$i) {
            $childNode = $node->childNodes->item($i);
            if ($childNode->nodeName == $nodeName) {
                return $childNode->textContent;
            }
        }
    }
}

class InspectionsFile
{
    /**
     * @var string
     */
    private $filePath;

    /**
     * @var InspectionProblem[]
     */
    private $problems = array();

    public function __construct($path)
    {
        $this->filePath = $path;
    }

    public function exists()
    {
        return file_exists($this->filePath);
    }

    public function load()
    {
        $dom = new DOMDocument();
        $dom->load($this->filePath);

        $problems = $dom->getElementsByTagName('problem');
        for ($i = 0; $i < $problems->length; ++$i) {
            $problem = $problems->item($i);

            $this->problems[] = new InspectionProblem($problem);
        }
    }

    public function printInspections()
    {
        foreach ($this->problems as $problem) {
            $problem->printOut();
        }
    }

    public static function processAndPrintInspections($path, $message)
    {
        $nonApiInspectionsFile = new InspectionsFile($path);
        if ($nonApiInspectionsFile->exists()) {
            echo "$message\n";

            $nonApiInspectionsFile->load();
            $nonApiInspectionsFile->printInspections();

            echo "\n";
        }
    }
}

InspectionsFile::processAndPrintInspections(
    "./output/PiwikNonApiInspection.xml", "## Usage of non-API classes and method");

InspectionsFile::processAndPrintInspections(
    "./output/PhpDeprecationInspection.xml", "## Usage of @deprecated code");

InspectionsFile::processAndPrintInspections(
    "./output/PhpUndefinedMethodInspection.xml", "## Usage of undefined methods");

